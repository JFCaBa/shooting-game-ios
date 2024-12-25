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
    @Published private(set) var isWalletConnected = false
    @Published private(set) var connectedWallet: String?
    @Published private(set) var showMetaMaskNotInstalledError = false
    
    private let web3Service = Web3Service.shared
    private let tokenService: TokenServiceProtocol
    
    init(tokenService: TokenServiceProtocol = TokenService()) {
        self.tokenService = tokenService
        checkExistingConnection()
    }
    
    func fetchBalance() {
        guard let playerId = GameManager.shared.playerId else { return }
        
        Task {
            do {
                balance = try await tokenService.getBalance(for: playerId)
            } catch {
                self.error = error
            }
        }
    }
    
    func checkConnection() async {
        if web3Service.isConnected {
            isConnected = true
            connectedWallet = web3Service.account
        }
        else {
            isConnected = false
            connectedWallet = nil
        }
    }
    
    private func checkExistingConnection() {
        isConnected = web3Service.isConnected
        connectedWallet = web3Service.account ?? GameManager.shared.playerId
    }
    
    func connect() async {
        guard web3Service.isMetaMaskInstalled() else {
            showMetaMaskNotInstalledError = true
            return
        }
        
        do {
            let walletAddress = try await web3Service.connect()
            isWalletConnected = true
            connectedWallet = walletAddress
            
            await updatePlayerWallet(walletAddress)
        } catch {
            isWalletConnected = false
            connectedWallet = GameManager.shared.playerId
            self.error = error
        }
    }

    private func updatePlayerWallet(_ wallet: String) async {
        // TODO: Update player wallet address in backend/storage
        
    }
    
    func disconnect() {
        web3Service.disconnect()
        isConnected = false
        connectedWallet = GameManager.shared.playerId
    }
    
    func openAppStore() {
        web3Service.openAppStore()
    }
}
