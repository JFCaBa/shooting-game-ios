//
//  GameManager.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreLocation
import CoreVideo
import FirebaseMessaging

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
    
    // MARK: - Private properties
    
    private let maxShootingDistance: CLLocationDistance = 500
    private let maximumAngleError: Double = 30
    private let locationManager = LocationManager.shared
    
    // MARK: - convenience init()
    
    convenience init() {
        self.init(
            webSocketService: WebSocketService(),
            playerManager: PlayerManagerService.shared
        )
    }
    
    // MARK: - init()
    
    init(
        webSocketService: WebSocketService,
        playerManager: PlayerManagerService
    ) {
        self.webSocketService = webSocketService
        self.playerManager = playerManager
        
        webSocketService.delegate = self
        setupLocation()
        setupObserver()
    }
    
    deinit {
        locationManager.stopLocationUpdates()
    }
    
    // MARK: - setupLocationUpdates()
    
    private func setupLocation() {
        locationManager.startLocationUpdates()
    }
    
    // MARK: - setupWalletObserver()
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlayerId),
            name: .metamaskDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerJoined(_:)),
            name: .playerJoined,
            object: nil
        )
    }
    
    // MARK: - playerJoined(_:)
    
    @objc private func playerJoined(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let player = userInfo["player"] as? Player
        else { return }
        
        let shoot = ShootData(from: player)
        playerManager.updatePlayer(shoot)
    }
    
    // MARK: - updatePlayerId()
    
    @objc private func updatePlayerId() {
        if let walletAddress = Web3Service.shared.account {
            playerId = walletAddress
            reconnectWithNewId()
        }
    }
    
    // MARK: - shoot(location:, heading:)
    
    func shoot(at point: CGPoint?, drone: DroneData?, location: LocationData, heading: Double) {
        guard let playerId = playerId, currentLives > 0 else { return }
        
        var message: GameMessage?
        
        if let drone {
            message = GameMessage(
                type: .shootDrone,
                playerId: playerId,
                data: .drone(drone),
                senderId: nil,
                pushToken: Messaging.messaging().fcmToken
            )
        }
        else {
            var shootData = ShootData()
            shootData.hitPlayerId = playerId
            shootData.damage = 1
            shootData.location = location
            shootData.heading = heading
            
            message = GameMessage(
                type: .shoot,
                playerId: playerId,
                data: .shoot(shootData),
                senderId: nil,
                pushToken: Messaging.messaging().fcmToken
            )
        }
        
        
        if let message {
            webSocketService.send(message: message)
        }
    }
    
    // MARK: - handleShot(_:)
    
    func handleShot(_ message: GameMessage) {
        guard
              let currentLocation = locationManager.location,
              currentLives > 0,
              isAlive,
              case let .shoot(shooterPlayer) = message.data,
              let shooterId = shooterPlayer.hitPlayerId,
              shooterId != playerId,
              let location = shooterPlayer.location
        else { return }
        
        let shooterLat = location.latitude
        let shooterLon = location.longitude
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
        let shooterHeading = shooterPlayer.heading
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
        let accuracy = location.accuracy
        let precision = accuracy / 2
        
        // Check if shoot hits player
        if abs(deviation) <= precision {
            NotificationCenter.default.post(name: .playerWasHit, object: nil)
            sendHitConfirmation(shotId: message.playerId, shooterId: shooterId)
        } else {
            sendShootConfirmation(shotId:  message.playerId, shooterId: shooterId, distance: realDistance, deviation: deviation)
        }
    }
    
    // MARK: - calculateDistance(from: lat1, lon1:, lat2:, lon2:)
    
    private func calculateDistance(from lat1: Double, _ lon1: Double, to lat2: Double, _ lon2: Double) -> Double {
        let location1 = CLLocation(latitude: lat1, longitude: lon1)
        let location2 = CLLocation(latitude: lat2, longitude: lon2)
        return location1.distance(from: location2)
    }
    
    // MARK: - sendHitConfirmation(shotId:, shooterId:)
    
    private func sendHitConfirmation(shotId: String, shooterId: String) {
        guard let playerId = playerId else { return }
        currentLives -= 1
        
        var shoot = ShootData()
        shoot.shotId = shooterId
        shoot.damage = 1
        
        let messageType: GameMessage.MessageType = currentLives <= 0 ? .kill : .hitConfirmed
        
        let message = GameMessage(
            type: messageType,
            playerId: playerId,
            data: .shoot(shoot),
            senderId: shooterId, // Dont change before changing in the Server
            pushToken: Messaging.messaging().fcmToken
        )
        
        webSocketService.send(message: message)
        
        if currentLives <= 0 {
            NotificationCenter.default.post(name: .playerDied, object: nil)
            respawnPlayer()
        }
    }
    
    // MARK: - sendShootConfirmation()
    
    private func sendShootConfirmation(shotId: String, shooterId: String, distance: Double, deviation: Double) {
        guard let playerId = playerId else { return }
                
        var shootData = ShootData()
        shootData.hitPlayerId = shooterId
        shootData.damage = 1
        shootData.distance = distance
        shootData.deviation = deviation
        
        let message = GameMessage(
            type: .shootConfirmed,
            playerId: playerId,
            data: .shoot(shootData),
            senderId: shooterId,
            pushToken: Messaging.messaging().fcmToken
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
            id: playerId ?? uuid(),
            location: LocationData(
                latitude: locationManager.location?.coordinate.latitude ?? 0,
                longitude: locationManager.location?.coordinate.longitude ?? 0,
                altitude: locationManager.location?.altitude ?? 0,
                accuracy: locationManager.location?.horizontalAccuracy ?? 0
            ),
            heading: locationManager.heading?.trueHeading ?? 0
//            timestamp: Date()
        )
    }
    
    // MARK: - reconnectWithNewId()
    
    private func reconnectWithNewId() {
        webSocketService.disconnect()
        webSocketService.connect()
    }
    
    // MARK: - startGame()
    
    func startGame() {
        startGame(retryCount: 5, retryDelay: 3.0)
    }
    
    func startGame(retryCount: Int = 3, retryDelay: TimeInterval = 2.0) {
        guard let location = locationManager.location,
              CLLocationCoordinate2DIsValid(location.coordinate) else {
            if retryCount > 0 {
                DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                    self?.startGame(retryCount: retryCount - 1, retryDelay: retryDelay)
                }
                print("Retrying startGame in \(retryDelay) seconds. Remaining attempts: \(retryCount - 1)")
            } else {
                print("Failed to start game: No valid coordinates after \(3 - retryCount) attempts.")
            }
            return
        }
        
        playerId = Web3Service.shared.account ?? uuid()
        currentLives = 10
        isAlive = true
        gameScore = GameScore(hits: 0, kills: 0)
        webSocketService.connect()
        playerManager.startHeartbeat()
    }
    
    // MARK: - uuid()
    
    /// Retrieves a UUID from the keychain if available.
    /// If no UUID is stored, generates a new one, saves it to the keychain, and returns it.
    /// This ensures a consistent identifier is maintained across app launches.
    ///
    /// - Returns: A `String` representation of the UUID.
    func uuid() -> String {
        if let storedUUID = try? KeychainManager.shared.readUUID() {
            return storedUUID
        } else {
            // Generate a new UUID
            let newUUID = UUID().uuidString
            try? KeychainManager.shared.saveUUID(newUUID)
            return newUUID
        }
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
}

// MARK: - WebSocketServiceDelegate

extension GameManager: WebSocketServiceDelegate {
    
    // MARK: DidConnect
    
    func webSocketDidConnect() {
        guard let playerId = playerId else { return }
        
        let message = GameMessage(
            type: .join,
            playerId: playerId,
            data: .player(self.createPlayerData()),
            senderId: nil,
            pushToken: Messaging.messaging().fcmToken
        )
        
        self.webSocketService.send(message: message)
    }
    
    // MARK: - DidDisconnect
    
    func webSocketDidDisconnect(error: Error?) {
        NotificationCenter.default.post(name: .connectionLost, object: error)
    }
    
    // MARK: - DidReceiveMessage
    
    func webSocketDidReceiveMessage(_ message: GameMessage) {
        switch message.type {
        case .join:
            if case let .player(player) = message.data {
                let shoot = ShootData(from: player)
                playerManager.updatePlayer(shoot)
            }
            
        case .shoot:
            if case let .shoot(shootData) = message.data, message.playerId != playerId {
                handleShot(message)
                playerManager.updatePlayer(shootData)
            }
            
        case .shootDrone:
            // Shouldn't arrive any message of this type, it is only to send
            break
            
        case .shootConfirmed:
            notifyShootConfirmed(message.data)
            
        case .hitConfirmed:
            if message.senderId == playerId, case let .shoot(shootData) = message.data {
                gameScore.hits += 1
                notifyHitConfirmed(shootData.damage)
            }
            
        case .kill:
            if message.senderId == playerId, case let .shoot(shootData) = message.data {
                gameScore.kills += 1
                notifyKill(shootData.hitPlayerId ?? "")
            }
            
        case .leave:
            CoreDataManager.shared.deletePlayer(id: message.playerId)
            
        case .hit:
            if case let .shoot(shootData) = message.data, shootData.hitPlayerId == playerId {
                currentLives -= (shootData.damage)
                if currentLives <= 0 {
                    NotificationCenter.default.post(name: .playerDied, object: nil)
                    respawnPlayer()
                }
            }
            
        case .announced:
            if case let .player(player) = message.data, message.playerId != playerId {
                CoreDataManager.shared.createOrUpdatePlayer(from: player)
            }
            
        case .newDrone:
            if case let .drone(droneData) = message.data, message.playerId == playerId {
                notifyNewDrone(droneData)
            }
        
        case .droneShootConfirmed:
            if case let .drone(droneData) = message.data, message.playerId == playerId {
                notifyDroneShootConfirmed(droneData)
            }
            
        case .droneShootRejected:
            break
        }
    }
    
    // MARK: - Send Notifications
    
    private func notifyDroneShootConfirmed(_ drone: DroneData) {
        NotificationCenter.default.post(
            name: .dronShootConfirmed,
            object: nil,
            userInfo: ["drone": drone]
        )
    }
    
    private func notifyShootConfirmed(_ data: MessageData) {
        NotificationCenter.default.post(
            name: .shootConfirmed,
            object: nil,
            userInfo: ["shootInfo": data]
        )
    }
    
    private func notifyNewDrone(_ drone: DroneData) {
        NotificationCenter.default.post(
            name: .newDroneArrived,
            object: nil,
            userInfo: ["drone": drone]
        )
    }
    
    private func notifyHitConfirmed(_ damage: Int) {
        NotificationCenter.default.post(
            name: .playerHitTarget,
            object: nil,
            userInfo: ["damage": damage]
        )
    }
    
    private func notifyKill(_ id: String) {
        NotificationCenter.default.post(
            name: .playerKilledTarget,
            object: nil,
            userInfo: ["targetId": id]
        )
    }
}
