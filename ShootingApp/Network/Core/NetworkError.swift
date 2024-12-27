//
//  NetworkError.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

enum NetworkError: Error, Equatable {
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
    
    var localizedDescription: String {
        switch self {
        case .unauthorized:
            return "Unauthorized access. Please check your credentials."
        case .badRequest:
            return "Invalid request. Please check your input."
        case .notFound:
            return "The requested resource was not found."
        case .serverError:
            return "An internal server error occurred. Please try again later."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .alreadyRegistered:
            return "This user is already registered."
        case .emailInUse:
            return "This email is already in use."
        case .invalidURL:
            return "Invalid URL provided."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .conflict(let message):
            return message
        case .unknown(let statusCode, let message):
            return "Unknown error occurred (Status: \(statusCode)): \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .unauthorized:
            return 401
        case .badRequest:
            return 400
        case .notFound:
            return 404
        case .serverError:
            return 500
        case .decodingFailed:
            return 1001
        case .requestFailed:
            return 1002
        case .alreadyRegistered:
            return 1003
        case .emailInUse:
            return 1004
        case .invalidURL:
            return 1005
        case .invalidResponse:
            return 1006
        case .conflict:
            return 409
        case .unknown(let statusCode, _):
            return statusCode
        }
    }
    
    var message: String {
        switch self {
        case .conflict(let message):
            return message
        default:
            return ""
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription &&
        lhs.errorCode == rhs.errorCode
    }
}
