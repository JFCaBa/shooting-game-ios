//
//  TokenService.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

final class TokenService: TokenServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getBalance(for address: String) async throws -> TokenResponse {
        let request = TokenBalanceRequest(walletAddress: address)
        let response: TokenResponse = try await networkClient.perform(request)
        return response
    }
}
