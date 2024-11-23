//
//  WalletUITest.swift
//  ShootingAppUITests
//
//  Created by Jose on 23/11/2024.
//

import XCTest

final class WalletUITests: XCTestCase {
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
    
    func testWalletButton_ShowsWalletSheet() {
        let walletButton = app.buttons["walletButton"]
        XCTAssertTrue(walletButton.exists)
        
        walletButton.tap()
        
        let connectButton = app.buttons["Connect MetaMask"]
        XCTAssertTrue(connectButton.waitForExistence(timeout: 2))
    }
    
    func testMetaMaskNotInstalled_ShowsAlert() {
        let walletButton = app.buttons["walletButton"]
        walletButton.tap()
        
        let connectButton = app.buttons["Connect MetaMask"]
        connectButton.tap()
        
        let alert = app.alerts["MetaMask Not Installed"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        
        XCTAssertTrue(alert.buttons["Install"].exists)
        XCTAssertTrue(alert.buttons["Cancel"].exists)
    }
    
    func testOnboarding_CanSkipWalletConnection() {
        let skipButton = app.buttons["Skip"]
        XCTAssertTrue(skipButton.exists)
        
        skipButton.tap()
        
        // Verify we're on the main game screen
        let shootButton = app.buttons["shootButton"]
        XCTAssertTrue(shootButton.waitForExistence(timeout: 2))
    }
    
    func testOnboarding_ShowsWalletConnectionOption() {
        let connectButton = app.buttons["Connect MetaMask"]
        XCTAssertTrue(connectButton.exists)
        
        let titleLabel = app.staticTexts["Connect & Earn"]
        XCTAssertTrue(titleLabel.exists)
        
        let descriptionLabel = app.staticTexts["Link MetaMask to collect rewards for your achievements in the game"]
        XCTAssertTrue(descriptionLabel.exists)
    }
}
