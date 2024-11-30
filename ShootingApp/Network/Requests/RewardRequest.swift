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
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
