//
//  GeoObjectServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

protocol GeoObjectServiceProtocol {
    func getNearbyObjects(latitude: Double, longitude: Double, radius: Double) async throws -> GeoObjectsResponse
}


