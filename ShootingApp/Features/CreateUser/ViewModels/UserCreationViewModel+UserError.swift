//
//  UserError.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Foundation

extension UserCreationViewModel {
    enum UserError: LocalizedError {
       case invalidEmail
       case invalidPassword
       case passwordMismatch
       case nicknameEmpty
       
       var errorDescription: String? {
           switch self {
           case .invalidEmail:
               return "Please enter a valid email address"
           case .invalidPassword:
               return "Password must be at least 8 characters and contain uppercase letter and number"
           case .passwordMismatch:
               return "Passwords do not match"
           case .nicknameEmpty:
               return "Nickname cannot be empty"
           }
       }
    }
}

