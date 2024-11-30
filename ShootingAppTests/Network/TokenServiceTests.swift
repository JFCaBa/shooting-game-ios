//
//  TokenServiceTests.swift
//  ShootingAppTests
//
//  Created by Jose on 30/11/2024.
//

import XCTest
@testable import ShootingApp

final class TokenServiceTests: XCTestCase {
    var sut: TokenService!
    var mockNetworkClient: MockNetworkClient!
    
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        sut = TokenService(networkClient: mockNetworkClient)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }
    
    func testGetBalance_Success() async throws {
        // Given
        let expectedBalance = "100"
        mockNetworkClient.result = TokenResponse(balance: expectedBalance)
        
        // When
        let balance = try await sut.getBalance(for: "0x123")
        
        // Then
        XCTAssertEqual(balance, expectedBalance)
    }
    
    func testGetBalance_NetworkError() async throws {
        // Given
        mockNetworkClient.error = NetworkError.invalidResponse
        
        // When/Then
        do {
            _ = try await sut.getBalance(for: "0x123")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }
}

final class MockNetworkClient: NetworkClientProtocol {
    var result: Any?
    var error: Error?
    
    func perform<T: Decodable>(_ request: NetworkRequest) async throws -> T {
        if let error = error {
            throw error
        }
        
        if let result = result as? T {
            return result
        }
        
        throw NetworkError.invalidResponse
    }
}
