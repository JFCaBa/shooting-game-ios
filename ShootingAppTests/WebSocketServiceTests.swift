//
//  WebSocketServiceTest.swift
//  ShootingAppTests
//
//  Created by Jose on 24/11/2024.
//

import XCTest
@testable import ShootingApp

final class WebSocketServiceTests: XCTestCase {
    var sut: WebSocketService!
    var mockDelegate: MockWebSocketDelegate!
    
    override func setUp() {
        super.setUp()
        sut = WebSocketService()
        mockDelegate = MockWebSocketDelegate()
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        sut = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testReconnectionAttemptsAfterDisconnection() {
        // Given
        let expectation = XCTestExpectation(description: "Reconnection attempts")
        mockDelegate.disconnectCallback = { error in
            expectation.fulfill()
        }
        
        // When
        sut.connect()
        sut.disconnect()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}

class MockWebSocketDelegate: WebSocketServiceDelegate {
    var connectCallback: (() -> Void)?
    var disconnectCallback: ((Error?) -> Void)?
    var messageCallback: ((GameMessage) -> Void)?
    
    func webSocketDidConnect() {
        connectCallback?()
    }
    
    func webSocketDidDisconnect(error: Error?) {
        disconnectCallback?(error)
    }
    
    func webSocketDidReceiveMessage(_ message: GameMessage) {
        messageCallback?(message)
    }
}
