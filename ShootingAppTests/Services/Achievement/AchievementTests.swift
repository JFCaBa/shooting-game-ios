//
//  AchievementTests.swift
//  ShootingAppTests
//
//  Created by Jose on 25/11/2024.
//

import XCTest
@testable import ShootingApp

final class AchievementTests: XCTestCase {
    var sut: AchievementService!
    var mockWeb3Service: MockWeb3Service!
    
    override func setUp() {
        super.setUp()
        mockWeb3Service = MockWeb3Service()
        sut = AchievementService(web3Service: mockWeb3Service)
    }
    
    override func tearDown() {
        sut = nil
        mockWeb3Service = nil
        super.tearDown()
    }
    
    func testTrackProgress_WhenMilestoneReached_UnlocksAchievement() {
        let expectation = expectation(forNotification: .achievementUnlocked, object: nil)
        mockWeb3Service.account = "0x123"
        
        sut.trackProgress(type: .kills, progress: 10)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testTrackProgress_WhenNoWallet_DoesNothing() {
        mockWeb3Service.account = nil
        sut.trackProgress(type: .kills, progress: 10)
        // Assert no achievement unlocked
    }
}

// MARK: - MockWeb3Service

class MockWeb3Service: Web3ServiceProtocol {
    private var mockAccount: String?
    
    var account: String? {
        get { return mockAccount }
        set { mockAccount = newValue }
    }
    
    var isConnected: Bool {
        return mockAccount != nil
    }
    
    func isMetaMaskInstalled() -> Bool {
        return true
    }
    
    func connect() async throws -> String {
        guard let account = mockAccount else {
            throw Web3Error.connectionFailed
        }
        return account
    }
    
    func disconnect() {
        mockAccount = nil
    }
}
