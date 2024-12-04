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
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
