//
//  GameManager.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreLocation

final class GameManager {
    static let shared = GameManager()
    private let webSocketService = WebSocketService()
    private let playerManager = PlayerManagerService.shared
    private let locationManager = CLLocationManager()
    private var playerId: String?
    private let maxShootingDistance: CLLocationDistance = 500
    private let maximumAngleError: Double = 30
    private var currentLives = 10
    private var isAlive = true
    public var gameScore = GameScore(hits: 0, kills: 0)
    
    private init() {
        webSocketService.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        setupWalletObserver()
    }
    
    private func setupWalletObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlayerId),
            name: NSNotification.Name("MetaMaskDidConnect"),
            object: nil
        )
    }
    
    @objc private func updatePlayerId() {
        if let walletAddress = Web3Service.shared.account {
            playerId = walletAddress
            reconnectWithNewId()
        }
    }
    
    func handleShot(_ message: GameMessage) {
        guard message.playerId != playerId,
              let currentLocation = locationManager.location,
              currentLives > 0,
              isAlive else { return }
        
        guard message.playerId != playerId,
              let currentLocation = locationManager.location,
              currentLives > 0 else { return }
        
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
        
        if angleDifference <= allowedError {
            NotificationCenter.default.post(name: .playerWasHit, object: nil)
            sendHitConfirmation(shotId: message.data.shotId ?? "", shooterId: message.playerId)
        }
    }
    
    private func sendHitConfirmation(shotId: String, shooterId: String) {
        guard let playerId = playerId else { return }
        currentLives -= 1
        
        let player = createPlayerData()
        let messageType: GameMessage.MessageType = currentLives <= 0 ? .kill : .hitConfirmed
        
        let messageData = MessageData(
            player: player,
            shotId: shotId,
            hitPlayerId: playerId,
            damage: 10
        )
        
        let message = GameMessage(
            type: messageType,
            playerId: playerId,
            data: messageData,
            timestamp: Date(),
            targetPlayerId: shooterId
        )
        
        webSocketService.send(message: message)
        
        if currentLives <= 0 {
            NotificationCenter.default.post(name: .playerDied, object: nil)
            respawnPlayer()
        }
    }
    
    private func respawnPlayer() {
        isAlive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            self?.currentLives = 10
            self?.isAlive = true
            NotificationCenter.default.post(name: .playerRespawned, object: nil)
        }
    }
    
    private func createPlayerData() -> Player {
        Player(
            id: playerId ?? "",
            location: LocationData(
                latitude: locationManager.location?.coordinate.latitude ?? 0,
                longitude: locationManager.location?.coordinate.longitude ?? 0,
                altitude: locationManager.location?.altitude ?? 0,
                accuracy: locationManager.location?.horizontalAccuracy ?? 0
            ),
            heading: locationManager.heading?.trueHeading ?? 0,
            timestamp: Date()
        )
    }
    
    private func reconnectWithNewId() {
        webSocketService.disconnect()
        webSocketService.connect()
    }
    
    func startGame() {
        playerId = Web3Service.shared.account ?? UUID().uuidString
        currentLives = 10
        isAlive = true
        gameScore = GameScore(hits: 0, kills: 0)
        webSocketService.connect()
        playerManager.startHeartbeat()
    }
    
    func shoot(location: LocationData, heading: Double) {
        guard let playerId = playerId, currentLives > 0 else { return }
        
        let messageData = MessageData(
            player: Player(
                id: playerId,
                location: location,
                heading: heading,
                timestamp: Date()
            ),
            shotId: UUID().uuidString,
            hitPlayerId: nil,
            damage: 0
        )
        
        let message = GameMessage(
            type: .shoot,
            playerId: playerId,
            data: messageData,
            timestamp: Date(),
            targetPlayerId: nil
        )
        
        webSocketService.send(message: message)
    }
    
    func endGame() {
        webSocketService.disconnect()
        playerManager.stopHeartbeat()
        playerId = nil
        currentLives = 10
        isAlive = true
        gameScore = GameScore(hits: 0, kills: 0)
    }
}

extension GameManager: WebSocketServiceDelegate {
    func webSocketDidConnect() {
        guard let playerId = playerId else { return }
        let message = GameMessage(
            type: .join,
            playerId: playerId,
            data: MessageData(
                player: createPlayerData(),
                shotId: nil,
                hitPlayerId: nil,
                damage: nil
            ),
            timestamp: Date(),
            targetPlayerId: nil
        )
        webSocketService.send(message: message)
    }
    
    func webSocketDidDisconnect(error: Error?) {
        NotificationCenter.default.post(name: .connectionLost, object: error)
    }
    
    func webSocketDidReceiveMessage(_ message: GameMessage) {
        switch message.type {
        case .join:
            playerManager.updatePlayer(message.data.player)
            
        case .shoot:
            handleShot(message)
            playerManager.updatePlayer(message.data.player)
            
        case .hitConfirmed:
            if message.targetPlayerId == playerId {
                gameScore.hits += 1
                NotificationCenter.default.post(
                    name: .playerHitTarget,
                    object: nil,
                    userInfo: ["damage": message.data.damage ?? 0]
                )
            }
            
        case .kill:
            if message.targetPlayerId == playerId {
                gameScore.kills += 1
                NotificationCenter.default.post(
                    name: .playerKilledTarget,
                    object: nil,
                    userInfo: ["targetId": message.data.hitPlayerId ?? ""]
                )
            }
            
        case .leave:
            CoreDataManager.shared.deletePlayer(id: message.playerId)
            
        case .hit:
            if message.data.hitPlayerId == playerId {
                currentLives -= (message.data.damage ?? 0)
                if currentLives <= 0 {
                    NotificationCenter.default.post(name: .playerDied, object: nil)
                    respawnPlayer()
                }
            }
        }
    }
}
