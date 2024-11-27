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
    
    override func setUp() {
        super.setUp()
        sut = Web3Service.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testIsMetaMaskInstalled_ReturnsFalseForInvalidURL() {
        let result = sut.isMetaMaskInstalled()
        XCTAssertFalse(result)
    }
    
    func testConnect_ThrowsErrorWhenMetaMaskNotInstalled() async {
        do {
            _ = try await sut.connect()
            XCTFail("Should throw error when MetaMask is not installed")
        } catch {
            XCTAssertTrue(error is Web3Error)
            XCTAssertEqual(error as? Web3Error, .metamaskNotInstalled)
        }
    }
    
    func testDisconnect_ClearsConnectedAccount() {
        sut.disconnect()
        XCTAssertNil(sut.account)
        XCTAssertFalse(sut.isConnected)
    }
}
