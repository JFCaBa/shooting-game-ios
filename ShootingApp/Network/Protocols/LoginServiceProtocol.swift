//
//  LoginServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Foundation

protocol LoginServiceProtocol {
    func sendLogin(email: String, password: String) async throws -> Player.Token
    func forgotPassword(email: String, playerId: String) async throws -> Player.ForgotPassword
}
