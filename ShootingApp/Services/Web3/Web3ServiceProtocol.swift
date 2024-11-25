//
//  Web3ServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import Foundation

protocol Web3ServiceProtocol {
    var account: String? { get }
    var isConnected: Bool { get }
    func isMetaMaskInstalled() -> Bool
    func connect() async throws -> String
    func disconnect()
}

extension Web3Service: Web3ServiceProtocol {}
