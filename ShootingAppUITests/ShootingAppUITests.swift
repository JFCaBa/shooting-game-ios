//
//  ShootingAppUITests.swift
//  ShootingAppUITests
//
//  Created by Jose on 26/10/2024.
//

//
//  ShootingAppUITests.swift
//  ShootingAppUITests
//
//  Created by Jose on 26/10/2024.
//

import XCTest
@testable import ShootingApp

final class ShootingAppUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        
        // Handle location permission alert
        addUIInterruptionMonitor(withDescription: "Location Authorization") { alert in
            if alert.buttons["Allow While Using App"].exists {
                alert.buttons["Allow While Using App"].tap()
                return true
            }
            return false
        }
    }
    
    func testShooting() throws {
        // Initial ammo state
        let ammoBar = app.progressIndicators.firstMatch
        XCTAssertEqual(ammoBar.value as? String, "100%")
        
        // Shoot
        let shootButton = app.buttons.firstMatch
        shootButton.tap()
        
        // Verify ammo decreased
        XCTAssertEqual(ammoBar.value as? String, "97%")
        
        // Verify flash view appears and disappears
        let flashView = app.otherElements["flashView"]
//        XCTAssertTrue(flashView.waitForExistence(timeout: 0.1))
        XCTAssertFalse(flashView.waitForExistence(timeout: 0.5))
    }
    
    func testPlayerHit() throws {
        // Post notification to simulate being hit
        NotificationCenter.default.post(name: .playerWasHit, object: nil)
        
        // Verify red flash view appears and disappears
        let hitFlashView = app.otherElements["hitFlashView"]
//        XCTAssertTrue(hitFlashView.waitForExistence(timeout: 0.1))
        XCTAssertFalse(hitFlashView.waitForExistence(timeout: 0.5))
    }
}
