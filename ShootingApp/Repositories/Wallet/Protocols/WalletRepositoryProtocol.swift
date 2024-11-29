//
//  WalletRepositoryProtocol.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import Foundation

protocol WalletRepositoryProtocol {
    func saveWalletAddress(_ address: String) throws
    func getWalletAddress() throws -> String?
    func deleteWalletAddress() throws
}
