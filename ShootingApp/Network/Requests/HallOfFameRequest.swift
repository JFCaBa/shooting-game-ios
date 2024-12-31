//
//  HallOfFameRequest.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

struct HallOfFameRequest: NetworkRequest {
    var body: Data?
        
    var path: String {
        "api/v1/halloffame/kills"
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
