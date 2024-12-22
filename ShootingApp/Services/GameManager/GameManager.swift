//
//  GameManager.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import CoreLocation
import CoreVideo
import FirebaseMessaging
import Foundation

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
    
    private var droneTimer: Timer?
    private var lastDroneTime: Date?
    private let droneTimeout: TimeInterval = 60 // 1 minute
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
    
    // MARK: - setupObserver()
    
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
    
    // MARK: - resetDroneTimer()
    
    private func resetDroneTimer() {
        let now = Date()
        if let lastTime = lastDroneTime, now.timeIntervalSince(lastTime) < droneTimeout {
            return
        }
        lastDroneTime = now
        droneTimer?.invalidate()
        DispatchQueue.main.async {
            self.droneTimer = Timer.scheduledTimer(withTimeInterval: self.droneTimeout, repeats: true) { [weak self] _ in
                self?.removeAllDrones()
                self?.removeDrones()
            }
        }
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
    
    // MARK: - shoot(ar:,drone:,geoObject:,location:,heading:))
    
    func shoot(at point: CGPoint?, drone: DroneData?, geoObject: GeoObject?, location: LocationData, heading: Double) {
        guard let playerId = playerId, currentLives > 0 else { return }
        
        // Create message based on input type
        let message: GameMessage?
        if let drone {
            message = createShootDroneMessage(playerId: playerId, drone: drone)
        } else if let geoObject {
            message = createShootGeoObjectMessage(playerId: playerId, geoObject: geoObject)
        } else {
            message = createShootMessage(playerId: playerId, location: location, heading: heading)
        }
        
        // Send the message if valid
        if let message {
            webSocketService.send(message: message)
        }
    }

    private func createShootDroneMessage(playerId: String, drone: DroneData) -> GameMessage {
        return GameMessage(
            type: .shootDrone,
            playerId: playerId,
            data: .drone(drone),
            senderId: nil,
            pushToken: nil
        )
    }

    private func createShootGeoObjectMessage(playerId: String, geoObject: GeoObject) -> GameMessage {
        return GameMessage(
            type: .shootGeoObject,
            playerId: playerId,
            data: .newGeoObject(geoObject),
            senderId: nil,
            pushToken: nil
        )
    }

    private func createShootMessage(playerId: String, location: LocationData, heading: Double) -> GameMessage {
        var shootData = ShootData()
        shootData.hitPlayerId = playerId
        shootData.damage = 1 // Default damage, configurable
        shootData.location = location
        shootData.heading = heading

        return GameMessage(
            type: .shoot,
            playerId: playerId,
            data: .shoot(shootData), // Pass the ShootData directly
            senderId: nil,
            pushToken: nil
        )
    }
    
    // MARK: - handleShot(_:)
    
    func handleShot(_ message: GameMessage, _ shootData: ShootData) {
        guard
            let currentLocation = locationManager.location,
            currentLives > 0,
            isAlive,
            let shooterId = shootData.hitPlayerId,
            shooterId != playerId,
            let location = shootData.location
        else {
            print("Invalid nested shoot data or conditions not met.")
            return
        }
        
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
        let shooterHeading = shootData.heading
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
            pushToken: nil
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
            pushToken: nil
        )
        
        webSocketService.send(message: message)
        
        if currentLives <= 0 {
            NotificationCenter.default.post(name: .playerDied, object: nil)
            respawnPlayer()
        }
    }
    
    // MARK: - removeDrones()
    
    /// Sends a message to the Server to remove all player drones
    private func removeDrones() {
        guard let playerId = playerId else { return }
        
        let message = GameMessage(
            type: .removeDrones,
            playerId: playerId,
            data: .empty,
            senderId: nil,
            pushToken: nil
        )
        
        webSocketService.send(message: message)
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
        print("\(message)")
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
            guard let shootData = message.data.shootData else {
                print("Shoot Data is nil")
                return
            }
            if message.playerId != playerId {
                handleShot(message, shootData)
                playerManager.updatePlayer(shootData)
            }
            
        case .shootConfirmed:
            guard let shootData = message.data.shootData else {
                print("Shoot Data is nil")
                return
            }
            notifyShootConfirmed(shootData)
            
        case .hitConfirmed:
            if message.senderId == playerId, case let .shootDataResponse(shootData) = message.data {
                gameScore.hits += 1
                notifyHitConfirmed(shootData.shoot?.damage ?? 1)
            }
            
        case .kill:
            if message.senderId == playerId, case let .shootDataResponse(shootData) = message.data {
                gameScore.kills += 1
                notifyKill(shootData.shoot?.hitPlayerId ?? "")
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
                let shoot = ShootData(from: player)
                playerManager.updatePlayer(shoot)
            }
            
        case .newDrone:
            if case let .drone(droneData) = message.data, message.playerId == playerId {
                resetDroneTimer()
                notifyNewDrone(droneData)
            }

        case .droneShootConfirmed:
            if case let .drone(droneData) = message.data, message.playerId == playerId {
                droneTimer?.invalidate()
                notifyDroneShootConfirmed(droneData)
            }
            
        case .droneShootRejected:
            break
        
        case .newGeoObject:
            if case let .newGeoObject(geoObject) = message.data {
                notifyNewGeoObject([geoObject])
            }
            
        case .geoObjectHit:
            if case let .newGeoObject(geoObject) = message.data {
                handleGeoObjectHit(geoObject)
            }
            
        case .geoObjectShootConfirmed:
            if case let .newGeoObject(geoObject) = message.data {
                handleGeoObjectShootConfirmed(geoObject)
            }
            
        case .geoObjectShootRejected:
            break;
            
        default:
            break
        }
    }
    
    private func handleGeoObjectHit(_ geoObject: GeoObject) {
            // Validate hit and send confirmation
            var shootData = ShootData()
            shootData.hitPlayerId = playerId
            shootData.damage = geoObject.metadata.reward ?? 1
            
            let message = GameMessage(
                type: .geoObjectShootConfirmed,
                playerId: playerId ?? "",
                data: .newGeoObject(geoObject),
                senderId: nil,
                pushToken: nil
            )
            
            webSocketService.send(message: message)
            
            // Notify UI
            NotificationCenter.default.post(
                name: .geoObjectHit,
                object: nil,
                userInfo: ["geoObject": geoObject]
            )
        }
        
        private func handleGeoObjectShootConfirmed(_ geoObject: GeoObject) {
            // Update score and notify
            gameScore.hits += 1
            
            NotificationCenter.default.post(
                name: .geoObjectShootConfirmed,
                object: nil,
                userInfo: [
                    "geoObject": geoObject
                ]
            )
        }
        
        func shootGeoObject(at point: CGPoint, geoObject: GeoObject) {
            guard let playerId = playerId else { return }
            
            let message = GameMessage(
                type: .geoObjectHit,
                playerId: playerId,
                data: .newGeoObject(geoObject),
                senderId: nil,
                pushToken: nil
            )
            
            webSocketService.send(message: message)
        }
        
    
    // MARK: - Send Notifications
    
    private func removeAllDrones() {
        NotificationCenter.default.post(
            name: .removeAllDrones,
            object: nil
        )
    }
    
    private func notifyDroneShootConfirmed(_ drone: DroneData) {
        NotificationCenter.default.post(
            name: .dronShootConfirmed,
            object: nil,
            userInfo: ["drone": drone]
        )
    }
    
    private func notifyShootConfirmed(_ data: ShootData) {
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
    
    private func notifyNewGeoObject(_ geoObject: [GeoObject]) {
        NotificationCenter.default.post(
            name: .newGeoObjectArrived,
            object: nil,
            userInfo: ["geoObject": geoObject]
        )
    }
}
