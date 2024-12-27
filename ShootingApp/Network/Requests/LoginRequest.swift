//
//  LoginRequest.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Foundation

struct LoginRequest: NetworkRequest {
    var body: Data? = nil
        
    var path: String {
        "api/v1/players/login"
    }
    
    var method: String { "POST" }
    
    var headers: [String: String] {
        return ["Content-Type": "application/json"]
    }
}
