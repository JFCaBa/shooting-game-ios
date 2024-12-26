//
//  NetworkError.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

enum NetworkError: Error,Equatable {
    case unauthorized
    case badRequest
    case notFound
    case serverError
    case decodingFailed(Error)
    case requestFailed(Error)
    case alreadyRegistered
    case emailInUse
    case invalidURL
    case invalidResponse
    case conflict(message: String)
    case unknown(statusCode: Int, message: String)
    
    var message: String {
        switch self {
        case .conflict(let message):
            return message
        default:
            return ""
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
