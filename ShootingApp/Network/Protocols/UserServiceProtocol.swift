//
//  UserServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Foundation

protocol UserServiceProtocol {
    func sendUserDetails(playerId: String, nickName: String, email: String, password: String) async throws -> Player.Token
    func getUserDetails(playerId: String) async throws -> Player.UserData
    func updateUser(playerId: String, nickName: String, email: String, password: String) async throws -> Void
}
