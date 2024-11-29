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
    func testCameraPermissionRequestFlow() {
        let sut = CameraPermissionViewModel()
        var results: [Bool] = []
        
        let expectation = self.expectation(description: "Camera permission")
        
        sut.permissionGranted
            .sink { granted in
                results.append(granted)
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        sut.requestPermission()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(results.isEmpty)
    }
    
    func testLocationPermissionRequestFlow() {
        let sut = LocationPermissionViewModel()
        var results: [Bool] = []
        
        let expectation = self.expectation(description: "Location permission")
        
        sut.permissionGranted
            .sink { granted in
                results.append(granted)
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        sut.requestPermission()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(results.isEmpty)
    }
    
    func testNotificationsPermissionRequestFlow() {
        let sut = NotificationsPermissionViewModel()
        var results: [Bool] = []
        
        let expectation = self.expectation(description: "Notifications permission")
        
        sut.permissionGranted
            .sink { granted in
                results.append(granted)
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        sut.requestPermission()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(results.isEmpty)
    }
    
    func testWalletConnectionRequestFlow() {
        let sut = WalletConnectionViewModel()
        var results: [Bool] = []
        
        let expectation = self.expectation(description: "Wallet connection")
        
        sut.permissionGranted
            .sink { granted in
                results.append(granted)
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        sut.requestPermission()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(results.isEmpty)
    }
}
