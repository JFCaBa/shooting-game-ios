//
//  OnboardingUITests.swift
//  ShootingAppTests
//
//  Created by Jose on 29/11/2024.
//

import XCTest

final class OnboardingUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testOnboardingFlow_CanSkipAllPermissions() {
        // Camera
        let cameraSkip = app.buttons["Skip"]
        XCTAssertTrue(cameraSkip.exists)
        cameraSkip.tap()
        
        // Location
        let locationSkip = app.buttons["Skip"]
        XCTAssertTrue(locationSkip.exists)
        locationSkip.tap()
        
        // Notifications
        let notificationsSkip = app.buttons["Skip"]
        XCTAssertTrue(notificationsSkip.exists)
        notificationsSkip.tap()
        
        // Wallet
        let walletSkip = app.buttons["Skip"]
        XCTAssertTrue(walletSkip.exists)
        walletSkip.tap()
        
        // Verify we're on the main game screen
        let shootButton = app.buttons["shootButton"]
        XCTAssertTrue(shootButton.waitForExistence(timeout: 2))
    }
    
    func testOnboardingFlow_ShowsMetaMaskError() {
        // Skip to wallet screen
        for _ in 0..<3 {
            app.buttons["Skip"].tap()
        }
        
        let connectButton = app.buttons["Connect MetaMask"]
        XCTAssertTrue(connectButton.exists)
        connectButton.tap()
        
        let alert = app.alerts["MetaMask Not Installed"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        
        XCTAssertTrue(alert.buttons["Install"].exists)
        XCTAssertTrue(alert.buttons["Cancel"].exists)
    }
}
