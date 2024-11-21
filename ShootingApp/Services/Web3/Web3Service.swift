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

    private var metaMaskSDK: MetaMaskSDK
    private var connectedAccount: String?
    private let DAPP_SCHEME = "shooting-app"

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
    
    func handleDeeplink(_ url: URL) {
        if let message = url.queryParameters?["message"],
           let data = Data(base64Encoded: message),
           let decoded = try? JSONDecoder().decode(MetaMaskResponse.self, from: data) {
            connectedAccount = decoded.data.accounts.first
        }
    }

    @discardableResult
    func connect() async throws -> String {
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

    var isConnected: Bool {
        return connectedAccount != nil
    }

    var account: String? {
        return connectedAccount
    }
}

struct MetaMaskResponse: Codable {
    let data: MetaMaskData
}

struct MetaMaskData: Codable {
    let chainId: String
    let accounts: [String]
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}
