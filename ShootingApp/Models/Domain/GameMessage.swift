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
    case drones([DroneData])
    case geoObject(GeoObject)
    case geoObjects([GeoObject])
    case empty
    
    private enum CodingKeys: String, CodingKey {
        case player, shoot, shootDataResponse, drone, drones, geoObject, geoObjects
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let player = try? container.decode(Player.self) {
            self = .player(player)
        } else if let shoot = try? container.decode(ShootData.self) {
            self = .shoot(shoot)
        } else if let drone = try? container.decode(DroneData.self) {
            self = .drone(drone)
        } else if let drones = try? container.decode([DroneData].self) {
            self = .drones(drones)
        } else if let geoObject = try? container.decode(GeoObject.self) {
            self = .geoObject(geoObject)
        } else if let geoObjects = try? container.decode([GeoObject].self) {
            self = .geoObjects(geoObjects)
        } else if let shootDataResponse = try? container.decode(ShootDataResponse.self) {
            self = .shootDataResponse(shootDataResponse)
        } else {
            self = .empty
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .player(let player):
            try container.encode(player, forKey: .player)
        case .shoot(let shoot):
            try container.encode(shoot, forKey: .shoot)
        case .drone(let drone):
            try container.encode(drone, forKey: .drone)
        case .drones(let drones):
            try container.encode(drones, forKey: .drones)
        case .geoObject(let geoObject):
            try container.encode(geoObject, forKey: .geoObject)
        case .geoObjects(let geoObjects):
            try container.encode(geoObjects, forKey: .geoObjects)
        case .shootDataResponse(let shootDataResponse):
            try container.encode(shootDataResponse, forKey: .shootDataResponse)
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

struct GameScore: Codable {
    var hits: Int
    var kills: Int
}

