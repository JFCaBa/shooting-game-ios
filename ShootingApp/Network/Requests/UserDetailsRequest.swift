//
//  UserDetailsRequest.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Foundation

struct UserDetailsRequest: NetworkRequest {
    var body: Data?
    
    let playerId: String
    
    var path: String {
        "api/v1/players/\(playerId)/details"
    }
    
    var method: String { "GET" }
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
