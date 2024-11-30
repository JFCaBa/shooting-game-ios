//
//  TokenServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

protocol TokenServiceProtocol {
    func getBalance(for address: String) async throws -> TokenResponse
}
