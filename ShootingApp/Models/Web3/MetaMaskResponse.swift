//
//  MetaMaskResponse.swift
//  ShootingApp
//
//  Created by Jose on 22/11/2024.
//

import Foundation

struct MetaMaskResponse: Codable {
    let data: MetaMaskData
}

struct MetaMaskData: Codable {
    let chainId: String
    let accounts: [String]
}
