//
//  Web3ServiceTest.swift
//  ShootingAppTests
//
//  Created by Jose on 21/11/2024.
//

import XCTest
@testable import ShootingApp

final class Web3ServiceTests: XCTestCase {
    var sut: Web3Service!
    var mockRepository: MockWalletRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockWalletRepository()
        sut = Web3Service.shared
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testIsMetaMaskInstalled_ReturnsFalseForInvalidURL() {
        let result = sut.isMetaMaskInstalled()
        XCTAssertFalse(result)
    }
    
    func testDisconnect_ClearsConnectedAccount() {
        sut.disconnect()
        XCTAssertNil(sut.account)
        XCTAssertFalse(sut.isConnected)
    }
}
