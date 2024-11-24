//
//  GameManager.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreLocation

final class GameManager: GameManagerProtocol {
    // MARK: - Singleton
    
    static let shared = GameManager()
    
    // MARK: - Exposed for testing
    
    private(set) var currentLives = 10
    private(set) var isAlive = true
    private(set) var playerId: String?
    public var gameScore = GameScore(hits: 0, kills: 0)
    
    // Dependencies that can be injected
    var webSocketService: WebSocketService
    var playerManager: PlayerManagerService
    var locationManager: CLLocationManager
    
    // MARK: - Private properties
    
    private let maxShootingDistance: CLLocationDistance = 500
    private let maximumAngleError: Double = 30
    
    // MARK: - convenience init()
    
    convenience init() {
        self.init(
            webSocketService: WebSocketService(),
            playerManager: PlayerManagerService.shared,
            locationManager: CLLocationManager()
        )
    }
    
    // MARK: - init()
    
    init(
        webSocketService: WebSocketService,
        playerManager: PlayerManagerService,
        locationManager: CLLocationManager
    ) {
        self.webSocketService = webSocketService
        self.playerManager = playerManager
        self.locationManager = locationManager
        
        webSocketService.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        setupWalletObserver()
    }
    
    // MARK: - setupWalletObserver()
    
    private func setupWalletObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlayerId),
            name: NSNotification.Name("MetaMaskDidConnect"),
            object: nil
        )
    }
    
    // MARK: - updatePlayerId()
    
    @objc private func updatePlayerId() {
        if let walletAddress = Web3Service.shared.account {
            playerId = walletAddress
            reconnectWithNewId()
        }
    }
    
    // MARK: - handleShot(_:)
    
    func handleShot(_ message: GameMessage) {
        guard message.playerId != playerId,
              let currentLocation = locationManager.location,
              currentLives > 0,
              isAlive else { return }
        
        let shooterLat = message.data.player.location.latitude
        let shooterLon = message.data.player.location.longitude
        let targetLat = currentLocation.coordinate.latitude
        let targetLon = currentLocation.coordinate.longitude
        
        // Calculate differences and real distance
        let shooterLocation = CLLocation(latitude: shooterLat, longitude: shooterLon)
        let latDiff = calculateDistance(from: shooterLat, shooterLon, to: targetLat, shooterLon)
        let lonDiff = calculateDistance(from: shooterLat, shooterLon, to: shooterLat, targetLon)
        let realDistance = currentLocation.distance(from: shooterLocation)
        
        // Calculate orientation and azimuth
        let orientation = atan2(lonDiff, latDiff) * 180 / .pi
        var azimuth: Double = 0
        
        // Calculate azimuth based on quadrant
        if targetLat < shooterLat && targetLon < shooterLon {
            azimuth = orientation
        } else if targetLat > shooterLat && targetLon < shooterLon {
            azimuth = 180 - orientation
        } else if targetLat > shooterLat && targetLon > shooterLon {
            azimuth = 180 + orientation
        } else if targetLat < shooterLat && targetLon > shooterLon {
            azimuth = 360 - orientation
        }
        
        // Calculate angle difference accounting for 360° wrap
        let shooterHeading = message.data.player.heading
        let degreeDiff: Double
        if shooterHeading < 90 && azimuth > 270 {
            degreeDiff = (360 - azimuth) + shooterHeading
        } else if shooterHeading > 270 && azimuth < 90 {
            degreeDiff = (360 - shooterHeading) + azimuth
        } else {
            degreeDiff = abs(shooterHeading - azimuth)
        }
        
        // Calculate shot deviation in meters
        let alpha = degreeDiff * .pi / 180
        let deviation = realDistance * tan(alpha)
        
        // Define precision based on accuracy
        let accuracy = message.data.player.location.accuracy
        let precision = accuracy / 2
        
        // Check if hit
        if abs(deviation) <= precision {
            NotificationCenter.default.post(name: .playerWasHit, object: nil)
            sendHitConfirmation(shotId: message.data.shotId ?? "", shooterId: message.playerId)
        }
    }

    private func calculateDistance(from lat1: Double, _ lon1: Double, to lat2: Double, _ lon2: Double) -> Double {
        let location1 = CLLocation(latitude: lat1, longitude: lon1)
        let location2 = CLLocation(latitude: lat2, longitude: lon2)
        return location1.distance(from: location2)
    }
    
    // MARK: - sendHitConfirmation(shotId:, shooterId:)
    
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
    
    // MARK: - respawnPlayer()
    
    // Public to be tested
    public func respawnPlayer() {
        isAlive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            self?.currentLives = 10
            self?.isAlive = true
            NotificationCenter.default.post(name: .playerRespawned, object: nil)
        }
    }
    
    // MARK: - createPlayerData()
    
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
    
    // MARK: - reconnectWithNewId()
    
    private func reconnectWithNewId() {
        webSocketService.disconnect()
        webSocketService.connect()
    }
    
    // MARK: - startGame()
    
    func startGame() {
        playerId = Web3Service.shared.account ?? UUID().uuidString
        currentLives = 10
        isAlive = true
        gameScore = GameScore(hits: 0, kills: 0)
        webSocketService.connect()
        playerManager.startHeartbeat()
    }
    
    // MARK: - endGame()
    
    func endGame() {
        webSocketService.disconnect()
        playerManager.stopHeartbeat()
        playerId = nil
        currentLives = 10
        isAlive = true
        gameScore = GameScore(hits: 0, kills: 0)
    }
    
    // MARK: - shoot(location:, heading:)
    
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
}

// MARK: - WebSocketServiceDelegate

extension GameManager: WebSocketServiceDelegate {
    
    // MARK: DidConnect
    
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
    
    // MARK: - DidDisconnect
    
    func webSocketDidDisconnect(error: Error?) {
        NotificationCenter.default.post(name: .connectionLost, object: error)
    }
    
    // MARK: - DidReceiveMessage
    
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

