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
    
    func testInitialState() {
        XCTAssertFalse(sut.isConnected)
    }
}
