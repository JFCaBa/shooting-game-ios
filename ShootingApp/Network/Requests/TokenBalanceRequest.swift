//
//  TokenBalanceRequest.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

struct TokenBalanceRequest: NetworkRequest {
    var body: Data?
    
    let walletAddress: String
    
    var path: String {
        "api/v1/players/\(walletAddress)/tokens"
    }
    
    var method: String { "GET" }
    
    private var token: String? {
        do {
            return try KeychainManager.shared.readToken()
        } catch {
            print("Error reading token: \(error.localizedDescription)")
            return nil
        }
    }
    
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
