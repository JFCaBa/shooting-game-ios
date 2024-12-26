//
//  UpdateUserRequest.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Foundation

struct UpdateUserRequest: NetworkRequest {
    let playerId: String
    
    private var token: String? {
        do {
            return try KeychainManager.shared.readToken()
        } catch {
            print("Error reading token: \(error.localizedDescription)")
            return nil
        }
    }
    
    let body: Data?
    
    var path: String {
        "api/v1/players/updatePlayerDetails"
    }
    
    var method: String { "PUT" }
    
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
