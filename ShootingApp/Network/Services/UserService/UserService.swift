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
        let userDetails = UserDetails(playerId: playerId, nickName: nickName, email: email, password: password)
        let encoder = JSONEncoder()
        let requestBody = try encoder.encode(userDetails)
        let request = UserDataRequest(body: requestBody)
        
        do {
            let response: Player.Token = try await networkClient.perform(request)
            return response
        } catch let networkError as NetworkError {
            switch networkError {
            case .conflict(let message):
                if message.contains("already registered") {
                    throw NetworkError.alreadyRegistered
                } else if message.contains("already in use") {
                    throw NetworkError.emailInUse
                }
                throw networkError
            default:
                throw networkError
            }
        }
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
    
    func updateUser(playerId: String, nickName: String, email: String, password: String) async throws  {
            let userDetails = UserDetails(playerId: playerId, nickName: nickName, email: email, password: password)
            
            do {
                let encoder = JSONEncoder()
                let requestBody = try encoder.encode(userDetails)
                let request = UpdateUserRequest(playerId: playerId, body: requestBody)
                
                let _: Player.Token = try await networkClient.perform(request)
            } catch let networkError as NetworkError {
                switch networkError {
                case .conflict(let message):
                    if message.contains("already registered") {
                        throw NetworkError.alreadyRegistered
                    } else if message.contains("already in use") {
                        throw NetworkError.emailInUse
                    }
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
                    throw networkError
                }
            }
        }
}
