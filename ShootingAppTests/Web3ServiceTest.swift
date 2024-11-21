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
    
    func testInitialState() {
        XCTAssertFalse(sut.isConnected)
    }
}
