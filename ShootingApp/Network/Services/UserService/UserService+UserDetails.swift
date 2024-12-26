//
//  UserService+UserDetails.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Foundation

extension UserService {
    struct UserDetails: Codable {
        let playerId: String?
        let nickName: String
        let email: String
        let password: String?
    }
}
