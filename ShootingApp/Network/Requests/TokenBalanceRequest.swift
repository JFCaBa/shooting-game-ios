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
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
