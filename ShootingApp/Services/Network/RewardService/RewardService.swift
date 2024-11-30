//
//  RewardService.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

final class RewardService: RewardServiceProtocol {

    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func adReward(for address: String) async throws -> RewardResponse {
        let request = RewardRequest(walletAddress: address)
        let response: RewardResponse = try await networkClient.perform(request)
        return response
    }
}
