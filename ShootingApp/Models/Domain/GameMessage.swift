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
        case leave
    }
    
    let type: MessageType
    let playerId: String
    let data: MessageData
    let timestamp: Date
}

struct MessageData: Codable {
    let player: Player
    let shotId: String?
    let hitPlayerId: String?
}
