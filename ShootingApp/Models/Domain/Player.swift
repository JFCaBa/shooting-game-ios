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
    var userData: UserData? = nil
    var wallet: String? = nil
    var token: Token? = nil
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let accuracy: Double
}

extension Player {
    struct Token: Codable {
        let token: String
    }
}


extension Player {
    struct UserData: Codable {
        let details: UserDetails?
    }
}

extension Player {
    struct UserDetails: Codable {
        let nickName: String?
        let email: String?
    }
}
