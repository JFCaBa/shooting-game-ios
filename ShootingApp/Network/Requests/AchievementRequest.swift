//
//  AchievementRequest.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

struct AchievementRequest: NetworkRequest {
    var body: Data?
    
    let walletAddress: String
    
    var path: String {
        "api/v1/players/\(walletAddress)/achievements"
    }
    
    var method: String { "GET" }
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
