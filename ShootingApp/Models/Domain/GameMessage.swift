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
        case hit
        case kill
        case hitConfirmed
        case leave
    }
    
    let type: MessageType
    let playerId: String
    let data: MessageData
    let timestamp: Date
    let targetPlayerId: String?
}

struct MessageData: Codable {
    let player: Player
    let shotId: String?
    let hitPlayerId: String?
    let damage: Int?
}

struct GameScore: Codable {
    var hits: Int
    var kills: Int
}
