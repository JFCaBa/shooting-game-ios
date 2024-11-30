//
//  TokenResponse.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

struct TokenResponse: Codable {
    let balance: Int
    let transferable: Int

    enum CodingKeys: String, CodingKey {
        case balance = "totalBalance"
        case transferable = "mintedBalance"
    }
}
