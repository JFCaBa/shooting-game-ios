//
//  RewardRequest.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

struct RewardRequestBody: Codable {
    let walletAddress: String
}

struct RewardRequest: NetworkRequest {
    let walletAddress: String
    
    var path: String {
        "api/v1/players/adReward"
    }
    
    var method: String { "POST" }
    
    var body: Data? {
        let body = RewardRequestBody(walletAddress: walletAddress)
        // Debugging: Print the body before encoding
        if let bodyData = try? JSONEncoder().encode(body),
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("Request Body: \(bodyString)")  // Check the body content before sending
        }
        return try? JSONEncoder().encode(body)
    }
    
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
