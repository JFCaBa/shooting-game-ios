//
//  WalletRepository.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import Foundation

final class WalletRepository: WalletRepositoryProtocol {
    private let keychainManager: KeychainManager
    private let service = "com.shootingapp.wallet"
    private let account = "walletAddress"
    
    init(keychainManager: KeychainManager = .shared) {
        self.keychainManager = keychainManager
    }
    
    func saveWalletAddress(_ address: String) throws {
        guard let data = address.data(using: .utf8) else { return }
        try keychainManager.save(data, service: service, account: account)
    }
    
    func getWalletAddress() throws -> String? {
        do {
            let data = try keychainManager.read(service: service, account: account)
            return String(data: data, encoding: .utf8)
        } catch KeychainError.itemNotFound {
            return nil
        }
    }
    
    func deleteWalletAddress() throws {
        try keychainManager.delete(service: service, account: account)
    }
}
