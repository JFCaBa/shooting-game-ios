//
//  UserDataRequest.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Foundation

struct UserDataRequest: NetworkRequest {
    var body: Data?
    
    var path: String {
        "api/v1/players/addPlayerDetails"
    }
    
    var method: String { "PUT" }
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
}
