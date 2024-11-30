//
//  NetworkRequest.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

protocol NetworkRequest {
    var path: String { get }
    var method: String { get }
    var body: Data? { get }
    var headers: [String: String] { get }
}
