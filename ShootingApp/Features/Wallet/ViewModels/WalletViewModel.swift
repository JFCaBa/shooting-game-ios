//
//  WalletViewModel.swift
//  ShootingApp
//
//  Created by Jose on 21/11/2024.
//

import Combine
import Foundation

@MainActor
final class WalletViewModel: ObservableObject  {
    @Published private(set) var balance: TokenResponse?
    @Published private(set) var error: Error?
    @Published private(set) var isConnected = false
    @Published private(set) var accountAddress: String?
    @Published private(set) var showMetaMaskNotInstalledError = false
    
    private let web3Service = Web3Service.shared
    private let tokenService: TokenServiceProtocol
    
    init(tokenService: TokenServiceProtocol = TokenService()) {
        self.tokenService = tokenService
        checkExistingConnection()
    }
    
    func fetchBalance(for address: String) {
        Task {
            do {
                balance = try await tokenService.getBalance(for: address)
            } catch {
                self.error = error
            }
        }
    }
    
    func checkConnection() async {
        if web3Service.isConnected {
            isConnected = true
            accountAddress = web3Service.account
        }
    }
    
    private func checkExistingConnection() {
        isConnected = web3Service.isConnected
        accountAddress = web3Service.account
    }
    
    func connect() async {
        guard web3Service.isMetaMaskInstalled() else {
            showMetaMaskNotInstalledError = true
            return
        }
        
        do {
            let account = try await web3Service.connect()
            isConnected = true
            accountAddress = account
        } catch {
            isConnected = false
            accountAddress = nil
            self.error = error
        }
    }
    
    func disconnect() {
        web3Service.disconnect()
        isConnected = false
        accountAddress = nil
    }
    
    func openAppStore() {
        web3Service.openAppStore()
    }
}
