//
//  NotificationManagerTests.swift
//  ShootingAppTests
//
//  Created by Jose on 02/12/2024.
//

import XCTest
@testable import ShootingApp

final class NotificationManagerTests: XCTestCase {
    var sut: NotificationManager!
    
    override func setUp() {
        super.setUp()
        sut = NotificationManager.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testHandleSilentNotification_WithInvalidType_CompletesWithNoData() {
        let expectation = XCTestExpectation(description: "Handle invalid notification")
        let userInfo: [AnyHashable: Any] = ["invalidKey": "invalidValue"]
        
        sut.handleSilentNotification(userInfo) { result in
            XCTAssertEqual(result, .noData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHandleSilentNotification_WithValidPlayerNearby_CompletesWithNewData() {
        let expectation = XCTestExpectation(description: "Handle player nearby")
        let userInfo: [AnyHashable: Any] = [
            "notificationType": "playerNearby",
            "playerName": "TestPlayer",
            "distance": 100
        ]
        
        sut.handleSilentNotification(userInfo) { result in
            XCTAssertEqual(result, .newData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
