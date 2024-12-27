//
//  LoginService.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Foundation

class LoginService: LoginServiceProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func sendLogin(email: String, password: String) async throws -> Player.Token {
        let userDetails = Player.UserDetails(email: email, password: password)
        let encoder = JSONEncoder()
        let requestBody = try encoder.encode(userDetails)
        let request = LoginRequest(body: requestBody)
        
        do {
            let response: Player.Token = try await networkClient.perform(request)
            return response
        } catch let networkError as NetworkError {
            throw networkError
        }
    }
    
    func forgotPassword(email: String, playerId: String) async throws -> Player.ForgotPassword {
        let details: [String: String] = ["email": email, "playerId": playerId]
        let encoder = JSONEncoder()
        let requestBody = try encoder.encode(details)
        let request = ForgotPasswordRequest(body: requestBody)
        
        do {
            let response: Player.ForgotPassword = try await networkClient.perform(request)
            return response
        } catch let networkError as NetworkError {
            throw networkError
        }
    }
    
}
