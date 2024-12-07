//
//  NetworkClient.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import Foundation

final class NetworkClient: NetworkClientProtocol {
    private let baseURL: String
    
    init(baseURL: String = Environment.apiURL.absoluteString) {
        self.baseURL = baseURL
    }
    
    func perform<T: Decodable>(_ request: NetworkRequest) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(request.path)") else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add the request body if it exists
        if let body = request.body {
            urlRequest.httpBody = body
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            // Debug: Print the raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
