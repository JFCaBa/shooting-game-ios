//
//  AchievementService.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import Foundation
import Web3Core

final class AchievementService: AchievementServiceProtocol {
    static let shared = AchievementService()
    private let web3Service: Web3ServiceProtocol
    private let coreDataManager: CoreDataManager
    
    init(web3Service: Web3ServiceProtocol = Web3Service.shared,
                coreDataManager: CoreDataManager = .shared) {
        self.web3Service = web3Service
        self.coreDataManager = coreDataManager
    }
    
    func trackProgress(type: AchievementType, progress: Int) {
        guard let wallet = web3Service.account else { return }
        
        let milestones = type.milestones.filter { $0 > progress }
        guard let nextMilestone = milestones.first else { return }
        
        let achievement = Achievement(
            id: UUID().uuidString,
            type: type,
            milestone: nextMilestone,
            progress: progress,
            walletAddress: wallet,
            unlockedAt: nil,
            nftTokenId: nil
        )
        
        if achievement.isUnlocked {
            Task {
                try? await unlockAchievement(achievement)
            }
        }
    }
    
    func unlockAchievement(_ achievement: Achievement) async throws {
        let metadata = AchievementNFTMetadata(
            achievementType: achievement.type,
            milestone: achievement.milestone,
            unlockedAt: Date(),
            walletAddress: achievement.walletAddress,
            signature: "" // Add signature logic
        )
        
        // Mint NFT logic here
        NotificationCenter.default.post(
            name: .achievementUnlocked,
            object: nil,
            userInfo: ["achievement": achievement]
        )
    }
    
    func getAchievements(for wallet: String) async throws -> [Achievement] {
        // Fetch from local storage or API
        return []
    }
}
