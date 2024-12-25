//
//  UserCreationViewModel.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Combine
import Foundation

final class UserCreationViewModel {
    weak var coordinator: SettingsCoordinator?
    @Published private(set) var error: Error?
    
    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return emailPredicate.evaluate(with: email)
    }
    
    func passwordsMatch(_ password: String, _ confirm: String) -> Bool {
        let hasMinLength = password.count >= 8
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasNumber = password.contains(where: { $0.isNumber })
        
        return hasMinLength && hasUppercase && hasNumber && password == confirm
    }
    
    func createUser(nickname: String, email: String, password: String, confirmPassword: String) {
        guard password == confirmPassword else {
            error = UserError.passwordMismatch
            return
        }
        
        //TODO: Add user creation logic
    }
}
