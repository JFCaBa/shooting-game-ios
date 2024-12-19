//
//  GeoObject.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import Foundation
import CoreLocation

struct GeoObject: Codable,Equatable {
    let id: String
    let type: GeoObjectType
    let coordinate: GeoCoordinate
    let metadata: GeoObjectMetadata
}

struct GeoCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct GeoObjectMetadata: Codable, Equatable {
    let reward: Int?
    let expiresAt: Date?
    let spawnedAt: Date
}

enum GeoObjectType: String, Codable, Equatable {
    case drone
    case target
    case powerup
}

// Response type for the API
typealias GeoObjectsResponse = [GeoObject]
