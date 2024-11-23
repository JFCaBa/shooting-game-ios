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
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = WalletViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testConnect_ShowsMetaMaskErrorWhenNotInstalled() async {
        let expectation = expectation(description: "Shows MetaMask not installed error")
        
        sut.$showMetaMaskNotInstalledError
            .dropFirst()
            .sink { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await sut.connect()
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testDisconnect_UpdatesConnectionState() {
        sut.disconnect()
        XCTAssertFalse(sut.isConnected)
    }
}
