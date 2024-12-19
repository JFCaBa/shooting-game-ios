//
//  GeoObjectService.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import Foundation

final class GeoObjectService: GeoObjectServiceProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func getNearbyObjects(latitude: Double, longitude: Double, radius: Double) async throws -> GeoObjectsResponse {
        let request = GeoObjectsRequest(
            latitude: latitude,
            longitude: longitude,
            radius: radius
        )
        return try await networkClient.perform(request)
    }
}
