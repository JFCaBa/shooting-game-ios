//
//  AuthServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Combine
import Foundation

protocol AuthServiceProtocol {
    /// Authenticates a user with email and password.
    /// - Parameters:
    ///   - email: The user's email.
    ///   - password: The user's password.
    /// - Returns: A publisher emitting a `Bool` indicating success or an error.
    func login(email: String, password: String) -> AnyPublisher<Bool, Error>
}
