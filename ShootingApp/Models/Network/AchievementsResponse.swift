//
//  AchievementsResponse.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

struct AchievementResponseElement: Codable {
    let id, playerID, type: String
    let milestone: Int
    let unlockedAt: String
    let v: Int
    let reward: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case playerID = "playerId"
        case type, milestone, unlockedAt
        case v = "__v"
        case reward
    }
}

typealias AchievementResponse = [AchievementResponseElement]

extension AchievementResponseElement {
    func toDomain() -> Achievement {
        return Achievement(
            id: id,
            type: AchievementType(rawValue: type.lowercased()) ?? .kills,
            milestone: milestone,
            progress: milestone, // Since it's unlocked, progress equals milestone
            walletAddress: playerID,
            unlockedAt: ISO8601DateFormatter().date(from: unlockedAt),
            nftTokenId: nil
        )
    }
}
