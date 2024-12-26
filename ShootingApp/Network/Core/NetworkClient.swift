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
        // Debugging: Print headers to check their contents
        print("Headers: \(request.headers)")
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Add the request body if it exists
        if let body = request.body {
            urlRequest.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(statusCode: -1, message: "Invalid response")
            }
            switch httpResponse.statusCode {
            case 200...299:
                // Debug: Print the raw JSON
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }

                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
                
            case 401:
                throw NetworkError.unauthorized
                
            case 400:
                throw NetworkError.badRequest
                
            case 404:
                throw NetworkError.notFound
                
            case 500...599:
                throw NetworkError.serverError
                
            default:
                throw NetworkError.unknown(
                    statusCode: httpResponse.statusCode,
                    message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                )
            }
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
