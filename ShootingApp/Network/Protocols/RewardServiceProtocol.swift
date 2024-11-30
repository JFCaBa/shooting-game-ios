//
//  RewardServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

protocol RewardServiceProtocol {
    func adReward(for address: String) async throws -> RewardResponse
}
