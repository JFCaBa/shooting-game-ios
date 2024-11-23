//
//  OnboardingViewModelTests.swift
//  ShootingAppTests
//
//  Created by Jose on 23/11/2024.
//

import XCTest
import Combine
@testable import ShootingApp

final class OnboardingViewModelTests: XCTestCase {
    var sut: OnboardingViewModel!
    var mockCoordinator: MockOnboardingCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockCoordinator = MockOnboardingCoordinator()
        sut = OnboardingViewModel()
        sut.coordinator = mockCoordinator
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testCheckMetaMaskAndProceed_ShowsErrorWhenNotInstalled() {
        let expectation = expectation(description: "Shows MetaMask not installed error")
        
        sut.$showMetaMaskNotInstalledError
            .dropFirst()
            .sink { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.checkMetaMaskAndProceed()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSkip_CallsFinishOnboarding() {
        sut.skip()
        XCTAssertTrue(mockCoordinator.finishOnboardingCalled)
    }
}

class MockOnboardingCoordinator: OnboardingCoordinator {
    var finishOnboardingCalled = false
    
    override func finishOnboarding() {
        finishOnboardingCalled = true
    }
}
