//
//  NetworkError.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}
