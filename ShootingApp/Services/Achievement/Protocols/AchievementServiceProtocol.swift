//
//  AchievementServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import Foundation

protocol AchievementServiceProtocol {
    func trackProgress(type: AchievementType, progress: Int)
    func unlockAchievement(_ achievement: Achievement) async throws
    func getAchievements(for wallet: String) async throws -> [Achievement]
}
