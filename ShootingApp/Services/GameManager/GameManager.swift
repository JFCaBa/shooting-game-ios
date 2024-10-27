//
//  GameManager.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreLocation

final class GameManager {
    // MARK: - Properties
    
    static let shared = GameManager()
    private let webSocketService = WebSocketService()
    private let playerManager = PlayerManagerService.shared
    private let locationManager = CLLocationManager()
    private var playerId: String?
    private let maxShootingDistance: CLLocationDistance = 500
    private let maximumAngleError: Double = 30
    
    private init() {
        webSocketService.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func startGame() {
        playerId = UUID().uuidString
        webSocketService.connect()
        playerManager.startHeartbeat()
    }
    
    func shoot(location: LocationData, heading: Double) {
        guard let playerId = playerId else { return }
        
        let player = Player(
            id: playerId,
            location: location,
            heading: heading,
            timestamp: Date()
        )
        
        let messageData = MessageData(
            player: player,
            shotId: UUID().uuidString,
            hitPlayerId: nil
        )
        
        let message = GameMessage(
            type: .shoot,
            playerId: playerId,
            data: messageData,
            timestamp: Date()
        )
        
        webSocketService.send(message: message)
    }
    
    func endGame() {
        webSocketService.disconnect()
        playerManager.stopHeartbeat()
        playerId = nil
    }
    
    private func handleShot(_ message: GameMessage) {
        guard message.playerId != playerId,
              let currentLocation = locationManager.location else { return }
        
        let shooterLocation = CLLocation(
            latitude: message.data.player.location.latitude,
            longitude: message.data.player.location.longitude
        )
        
        let distance = currentLocation.distance(from: shooterLocation)
        guard distance <= maxShootingDistance else { return }
        
        let bearing = shooterLocation.bearing(to: currentLocation)
        let angleDifference = abs(bearing - message.data.player.heading)
        let accuracy = message.data.player.location.accuracy
        let allowedError = maximumAngleError * (accuracy / 100)
        
        print(angleDifference)
        
        if angleDifference <= allowedError {
            NotificationCenter.default.post(name: .playerWasHit, object: nil)
            handleHit(shotId: message.data.shotId ?? "", shooterId: message.playerId)
        }
    }
    
    private func handleHit(shotId: String, shooterId: String) {
        guard let playerId = playerId else { return }
        
        let player = Player(
            id: playerId,
            location: LocationData(
                latitude: locationManager.location?.coordinate.latitude ?? 0,
                longitude: locationManager.location?.coordinate.longitude ?? 0,
                altitude: locationManager.location?.altitude ?? 0,
                accuracy: locationManager.location?.horizontalAccuracy ?? 0
            ),
            heading: locationManager.heading?.trueHeading ?? 0,
            timestamp: Date()
        )
        
        let messageData = MessageData(
            player: player,
            shotId: shotId,
            hitPlayerId: playerId
        )
        
        let message = GameMessage(
            type: .hit,
            playerId: shooterId,
            data: messageData,
            timestamp: Date()
        )
        
        webSocketService.send(message: message)
    }
}

// MARK: - WebSocketServiceDelegate

extension GameManager: WebSocketServiceDelegate {
    func webSocketDidConnect() {
        guard let playerId = playerId else { return }
        let player = Player(
            id: playerId,
            location: LocationData(
                latitude: locationManager.location?.coordinate.latitude ?? 0,
                longitude: locationManager.location?.coordinate.longitude ?? 0,
                altitude: locationManager.location?.altitude ?? 0,
                accuracy: locationManager.location?.horizontalAccuracy ?? 0
            ),
            heading: locationManager.heading?.trueHeading ?? 0,
            timestamp: Date()
        )
        
        let message = GameMessage(
            type: .join,
            playerId: playerId,
            data: MessageData(player: player, shotId: nil, hitPlayerId: nil),
            timestamp: Date()
        )
        
        webSocketService.send(message: message)
    }
    
    func webSocketDidDisconnect(error: Error?) {
        // Handle disconnection
    }
    
    func webSocketDidReceiveMessage(_ message: GameMessage) {
        switch message.type {
        case .join:
            playerManager.updatePlayer(message.data.player)
        case .shoot:
            handleShot(message)
            playerManager.updatePlayer(message.data.player)
        case .leave:
            CoreDataManager.shared.deletePlayer(id: message.playerId)
        case .hit:
            if message.playerId == playerId {
                NotificationCenter.default.post(name: .playerHitTarget, object: nil)
            }
        }
    }
}
