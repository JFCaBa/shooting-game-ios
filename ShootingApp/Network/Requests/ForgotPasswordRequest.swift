//
//  ForgotPasswordRequest.swift
//  ShootingApp
//
//  Created by Jose on 27/12/2024.
//

import Foundation

struct ForgotPasswordRequest: NetworkRequest {
    var body: Data? = nil
        
    var path: String {
        "api/v1/players/forgotPassword"
    }
    
    var method: String { "POST" }
    
    var headers: [String: String] {
        return ["Content-Type": "application/json"]
    }
}
