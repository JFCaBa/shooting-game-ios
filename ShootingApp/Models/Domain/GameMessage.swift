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
        case shootDrone
        case shootConfirmed
        case hit
        case kill
        case hitConfirmed
        case leave
        case announced
    }
    
    let type: MessageType
    let playerId: String
    let data: MessageData
//    let timestamp: Date
    let senderId: String?
    let pushToken: String?
    
    init(type: MessageType, playerId: String, data: MessageData, timestamp: Date, senderId: String? = nil, pushToken: String? = nil) {
        self.type = type
        self.playerId = playerId
        self.data = data
//        self.timestamp = timestamp
        self.senderId = senderId
        self.pushToken = pushToken
    }
}

struct MessageData: Codable {
    let player: Player
    let shotId: String?
    let hitPlayerId: String?
    let damage: Int?
    var distance: Double? = nil
    var deviation: Double? = nil
}

struct GameScore: Codable {
    var hits: Int
    var kills: Int
}
