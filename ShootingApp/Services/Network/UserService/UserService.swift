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
        
        do {
            let response: Player.UserData = try await networkClient.perform(request)
            return response
        } catch let networkError as NetworkError {
            switch networkError {
            case .unauthorized:
                // Handle 401 Unauthorized
                print("Unauthorized access. Please check the token.")
                throw networkError
            case .notFound:
                // Handle 404 Not Found
                print("User details not found for playerId: \(playerId).")
                throw networkError
            case .serverError:
                // Handle 500 Internal Server Error
                print("Server error occurred.")
                throw networkError
            default:
                // Handle other network errors (e.g., decoding, request issues)
                print("An unexpected error occurred: \(networkError).")
                throw networkError
            }
        } catch {
            // Re-throw any other non-NetworkError errors
            throw error
        }
    }
    
    func updateUser(playerId: String, nickName: String, email: String, password: String) async throws {
        
    }
}
