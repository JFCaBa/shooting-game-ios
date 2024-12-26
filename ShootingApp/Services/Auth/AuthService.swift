//
//  AuthService.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Combine
import Foundation

final class AuthService: AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        // Mock implementation
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                if email == "test@example.com" && password == "password" {
                    promise(.success(true))
                } else {
                    promise(.failure(NSError(domain: "InvalidCredentials", code: 401, userInfo: nil)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
