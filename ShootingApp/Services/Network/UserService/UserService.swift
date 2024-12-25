//
//  UserService.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Foundation

class UserService: UserServiceProtocol {

    

    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func sendUserDetails(playerId: String, nickName: String, email: String, password: String) async throws -> Player.Token {
        // Create the user details object
        let userDetails = UserDetails(playerId: playerId, nickName: nickName, email: email, password: password)
        
        // Encode the user details to JSON data
        let encoder = JSONEncoder()
        let requestBody = try encoder.encode(userDetails)
        
        // Create the request
        let request = UserDataRequest(body: requestBody)
        let response: Player.Token = try await networkClient.perform(request)
        
        return response
    }
    
    func getUserDetails(playerId: String) async throws -> Player.UserData {
        let request = UserDetailsRequest(playerId: playerId)
        let response: Player.UserData = try await networkClient.perform(request)
        return response
    }
    
    func updateUser(playerId: String, nickName: String, email: String, password: String) async throws {
        
    }
}
