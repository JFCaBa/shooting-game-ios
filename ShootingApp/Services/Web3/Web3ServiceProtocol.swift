//
//  Web3ServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import Foundation

protocol Web3ServiceProtocol {
    var isConnected: Bool { get }
    var account: String? { get }
    func isMetaMaskInstalled() -> Bool
    func openAppStore()
    func connect() async throws -> String
    func disconnect()
    func handleDeeplink(_ url: URL)
}
