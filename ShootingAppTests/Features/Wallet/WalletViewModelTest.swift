//
//  WalletViewModelTest.swift
//  ShootingAppTests
//
//  Created by Jose on 21/11/2024.
//

import XCTest
import Combine
@testable import ShootingApp

final class WalletViewModelTests: XCTestCase {
    var sut: WalletViewModel!
    var mockTokenService: MockTokenService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        await MainActor.run {
            mockTokenService = MockTokenService()
            sut = WalletViewModel(tokenService: mockTokenService)
            cancellables = []
        }
    }
    
    override func tearDown() {
        sut = nil
        mockTokenService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchBalance_Success() async {
        // Given
        let expectation = expectation(description: "Balance updated")
        let expectedBalance = "100"
        mockTokenService.balance = expectedBalance
        
        await MainActor.run {
            sut.$balance
                .dropFirst()
                .sink { balance in
                    XCTAssertEqual(balance, expectedBalance)
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            // When
            sut.fetchBalance(for: "0x123")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testFetchBalance_Error() async {
        // Given
        let expectation = expectation(description: "Error occurred")
        mockTokenService.error = NetworkError.invalidResponse
        
        await MainActor.run {
            sut.$error
                .dropFirst()
                .sink { error in
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            // When
            sut.fetchBalance(for: "0x123")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}

final class MockTokenService: TokenServiceProtocol {
    var balance: String?
    var error: Error?
    
    func getBalance(for address: String) async throws -> String {
        if let error = error {
            throw error
        }
        return balance ?? ""
    }
}
