//
//  NetworkError.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

enum NetworkError: Error {
    case unauthorized
    case badRequest
    case notFound
    case serverError
    case decodingFailed(Error)
    case requestFailed(Error)
    case invalidURL
    case invalidResponse
    case unknown(statusCode: Int, message: String)
}
