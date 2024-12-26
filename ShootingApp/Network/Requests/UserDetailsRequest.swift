//
//  UserDetailsRequest.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Foundation

struct UserDetailsRequest: NetworkRequest {
    var body: Data? = nil 
    
    let playerId: String
    
    private var token: String? {
        do {
            return try KeychainManager.shared.readToken()
        } catch {
            print("Error reading token: \(error.localizedDescription)")
            return nil
        }
    }
    
    var path: String {
        "api/v1/players/\(playerId)/details"
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
