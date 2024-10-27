//
//  Player.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreLocation

struct Player: Codable {
    let id: String
    let location: LocationData
    let heading: Double
    let timestamp: Date
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let accuracy: Double
}
