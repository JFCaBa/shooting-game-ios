//
//  HallOfFameService.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

final class HallOfFameService: HallOfFameServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getHallOfFame() async throws -> HallOfFameResponse {
        let request = HallOfFameRequest()
        let response: HallOfFameResponse = try await networkClient.perform(request)
        return response
    }
}
