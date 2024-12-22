//
//  GeoObject.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import UIKit
import CoreLocation

struct GeoObject: Codable, Equatable {
    let id: String
    let type: GeoObjectType
    let coordinate: GeoCoordinate
    let metadata: GeoObjectMetadata

    private enum CodingKeys: String, CodingKey {
        case id, type, coordinate, metadata
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(GeoObjectType.self, forKey: .type)
        coordinate = try container.decode(GeoCoordinate.self, forKey: .coordinate)
        metadata = try container.decode(GeoObjectMetadata.self, forKey: .metadata)
    }
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

    private enum CodingKeys: String, CodingKey {
        case reward
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reward = try container.decodeIfPresent(Int.self, forKey: .reward)
    }
}

enum GeoObjectType: String, Codable, Equatable {
    case weapon
    case target
    case powerup
    case unknown // Fallback for unexpected types
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = GeoObjectType(rawValue: rawValue) ?? .unknown
    }
    
    var colour: UIColor {
        switch self {
        case .weapon:
            return .systemBlue
        case .target:
            return .systemRed
        case .powerup:
            return .systemYellow
        default:
            return .systemOrange
        }
    }
    
    var image: UIImage {
        switch self {
        case .weapon:
            return UIImage(named: "ak-47")!
        case .target:
            return UIImage(systemName: "target")!
        case .powerup:
            return UIImage(systemName: "shippingbox.fill")!
        case .unknown:
            return UIImage(systemName: "arrow.2.circlepath.circle")!
        }
    }
}

// Response type for the API
typealias GeoObjectsResponse = [GeoObject]
