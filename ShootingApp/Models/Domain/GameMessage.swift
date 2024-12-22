//
//  GameMessage.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation

struct GameMessage: Codable {
    enum MessageType: String, Codable {
        case join
        case shoot
        case newDrone
        case shootDrone
        case shootConfirmed
        case hit
        case kill
        case hitConfirmed
        case leave
        case announced
        case droneShootConfirmed
        case droneShootRejected
        case removeDrones
        case shootGeoObject
        case newGeoObject
        case geoObjectHit
        case geoObjectShootConfirmed
        case geoObjectShootRejected
    }
    
    let type: MessageType
    let playerId: String
    let data: MessageData
    let senderId: String?
    let pushToken: String?
    
    init(type: MessageType, playerId: String, data: MessageData, senderId: String? = nil, pushToken: String? = nil) {
        self.type = type
        self.playerId = playerId
        self.data = data
        self.senderId = senderId
        self.pushToken = pushToken
    }
}

enum MessageData: Codable {
    case player(Player)
    case shoot(ShootData)
    case shootDataResponse(ShootDataResponse)
    case drone(DroneData)
    case newGeoObject(GeoObject)
    case empty
    
    private enum CodingKeys: String, CodingKey {
        case kind // Discriminator field
    }
    
    private enum Kind: String, Codable {
        case player
        case shoot
        case shootDataResponse
        case drone
        case geoObject
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        
        switch kind {
        case .player:
            self = .player(try Player(from: decoder))
        case .shoot:
            self = .shoot(try ShootData(from: decoder))
        case .shootDataResponse:
            self = .shootDataResponse(try ShootDataResponse(from: decoder))
        case .drone:
            self = .drone(try DroneData(from: decoder))
        case .geoObject:
            self = .newGeoObject(try GeoObject(from: decoder))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .player(let player):
            try container.encode("player", forKey: .kind)
            try player.encode(to: encoder)
        case .shoot(let shoot):
            try container.encode("shoot", forKey: .kind)
            try shoot.encode(to: encoder)
        case .shootDataResponse(let shootDataResponse):
            try container.encode("shootDataResponse", forKey: .kind)
            try shootDataResponse.encode(to: encoder)
        case .drone(let drone):
            try container.encode("drone", forKey: .kind)
            try drone.encode(to: encoder)
        case .newGeoObject(let newGeoObject):
            try container.encode("geoObject", forKey: .kind)
            try newGeoObject.encode(to: encoder)
        case .empty:
            break
        }
    }
}

struct DroneData: Codable, Equatable {
    var droneId: String
    var position: Position3D
    let reward: Int?
}

struct Position3D: Codable, Equatable {
    let x: Float
    let y: Float
    let z: Float
}

struct ShootDataResponse: Codable {
    let shoot: ShootData?
}

struct ShootData: Codable {
    var shoot: InnerShootData? // Update to represent the nested structure
    var shotId: String?
    var hitPlayerId: String?
    var damage: Int = 1
    var distance: Double = 0
    var deviation: Double = 0
    var heading: Double = 0
    var location: LocationData?
    
    init() {
        shotId = nil
        hitPlayerId = nil
        location = nil
    }
    
    init(from: Player) {
        shotId = UUID().uuidString
        hitPlayerId = from.id
        location = nil
    }
}

struct InnerShootData: Codable {
    var shotId: String?
    var hitPlayerId: String?
    var damage: Int = 1
    var distance: Double = 0
    var deviation: Double = 0
    var heading: Double = 0
    var location: LocationData?
}

struct GameScore: Codable {
    var hits: Int
    var kills: Int
}


// MARK: - MessageData Extension

extension MessageData {
    var shootDataResponse: ShootDataResponse? {
        if case let .shootDataResponse(data) = self {
            return data
        }
        return nil
    }
    
    var shootData: ShootData? {
        if case let .shoot(data) = self {
            return data
        }
        return nil
    }
}
