//
//  AchievementType.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import Foundation

enum AchievementType: String, Codable {
    case kills
    case hits
    case survivalTime
    case accuracy
    
    var description: String {
        switch self {
        case .kills: return "Total Kills"
        case .hits: return "Total Hits"
        case .survivalTime: return "Survival Time"
        case .accuracy: return "Accuracy"
        }
    }
    
    var milestones: [Int] {
        switch self {
        case .kills: return [10, 50, 100, 500, 1000]
        case .hits: return [100, 500, 1000, 5000]
        case .survivalTime: return [3600, 18000, 86400] // In seconds
        case .accuracy: return [50, 75, 90, 95] // Percentage
        }
    }
}

struct Achievement: Codable {
    let id: String
    let type: AchievementType
    let milestone: Int
    let progress: Int
    let walletAddress: String
    let unlockedAt: Date?
    let nftTokenId: String?
    
    var isUnlocked: Bool {
        return progress >= milestone
    }
}

struct AchievementNFTMetadata: Codable {
    let achievementType: AchievementType
    let milestone: Int
    let unlockedAt: Date
    let walletAddress: String
    let signature: String
}
