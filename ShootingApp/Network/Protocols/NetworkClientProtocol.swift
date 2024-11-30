//
//  NetworkClientProtocol.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

protocol NetworkClientProtocol {
    func perform<T: Decodable>(_ request: NetworkRequest) async throws -> T
}
