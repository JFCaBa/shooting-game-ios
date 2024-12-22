//
//  Player.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreLocation

struct Player: Codable {
    let playerId: String
    let location: LocationData
    let heading: Double
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let accuracy: Double
}
