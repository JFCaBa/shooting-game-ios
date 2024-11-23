//
//  Web3Service.swift
//  ShootingApp
//
//  Created by Jose on 21/11/2024.
//

import metamask_ios_sdk
import UIKit

class Web3Service {
    static let shared = Web3Service()
    
    private let metamaskAppId = "1438144202"
    private var metaMaskSDK: MetaMaskSDK
    private var connectedAccount: String?
    private let DAPP_SCHEME = "shooting-app"
    
    var isConnected: Bool {
        return connectedAccount != nil
    }
    
    var account: String? {
        return connectedAccount
    }
    
    private init() {
        let appMetadata = AppMetadata(
            name: "ShootingApp",
            url: "https://onedayvpn.com"
        )
        
        metaMaskSDK = MetaMaskSDK.shared(
            appMetadata,
            transport: .deeplinking(dappScheme: DAPP_SCHEME),
            sdkOptions: nil
        )
    }
    
    func isMetaMaskInstalled() -> Bool {
            guard let url = URL(string: "metamask://") else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
        
        func openAppStore() {
            guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(metamaskAppId)") else { return }
            UIApplication.shared.open(url)
        }
    
    func handleDeeplink(_ url: URL) {
        if let message = url.queryParameters?["message"],
           let data = Data(base64Encoded: message),
           let decoded = try? JSONDecoder().decode(MetaMaskResponse.self, from: data) {
            connectedAccount = decoded.data.accounts.first
            notifyConnectionChanged()
        }
    }
    
    @discardableResult
        func connect() async throws -> String {
            guard isMetaMaskInstalled() else {
                throw Web3Error.metamaskNotInstalled
            }
            
            let result = await metaMaskSDK.connect()
            switch result {
            case .success(let accounts):
                guard let account = accounts.first else {
                    throw Web3Error.connectionFailed
                }
                connectedAccount = account
                return account
            case .failure:
                throw Web3Error.connectionFailed
            }
        }
    
    func disconnect() {
        metaMaskSDK.disconnect()
        connectedAccount = nil
    }
    
    private func notifyConnectionChanged() {
        NotificationCenter.default.post(
            name: NSNotification.Name("WalletConnectionChanged"),
            object: nil
        )
    }
}
