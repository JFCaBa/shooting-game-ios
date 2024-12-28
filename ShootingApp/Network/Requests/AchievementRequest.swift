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
    
    private var token: String? {
        do {
            return try KeychainManager.shared.readToken()
        } catch {
            print("Error reading token: \(error.localizedDescription)")
            return nil
        }
    }
    
    var path: String {
        "api/v1/players/\(walletAddress)/achievements"
    }
    
    var method: String { "GET" }
    
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
