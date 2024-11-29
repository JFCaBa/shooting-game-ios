//
//  MockWalletRepository.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import Foundation

class MockWalletRepository: WalletRepositoryProtocol {
    var savedAddress: String?
    var shouldThrowError = false
    
    func saveWalletAddress(_ address: String) throws {
        if shouldThrowError { throw KeychainError.unexpectedStatus(1) }
        savedAddress = address
    }
    
    func getWalletAddress() throws -> String? {
        if shouldThrowError { throw KeychainError.unexpectedStatus(1) }
        return savedAddress
    }
    
    func deleteWalletAddress() throws {
        if shouldThrowError { throw KeychainError.unexpectedStatus(1) }
        savedAddress = nil
    }
}
