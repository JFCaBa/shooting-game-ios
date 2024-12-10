//
//  HallOfFameResponse.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

struct HallOfFameResponseElement: Codable {
    let stats: Stats
    let id: String
    let playerID: String?

    enum CodingKeys: String, CodingKey {
        case stats
        case id = "_id"
        case playerID = "playerId"
    }
}

// MARK: - Stats
struct Stats: Codable {
    let hits, kills: Int
    let droneHits: Int?
}

typealias HallOfFameResponse = [HallOfFameResponseElement]
