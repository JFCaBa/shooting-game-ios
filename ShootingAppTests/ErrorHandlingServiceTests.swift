//
//  ErrorHandlingServiceTests.swift
//  ShootingAppTests
//
//  Created by Jose on 24/11/2024.
//

import XCTest
import CoreData
@testable import ShootingApp

final class ErrorHandlingServiceTests: XCTestCase {
    var sut: ErrorHandlingService!
    
    override func setUp() {
        super.setUp()
        sut = ErrorHandlingService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testHandleCoreDataError_PostsNotification() {
        // Given
        let expectation = expectation(forNotification: .coreDataErrorOccurred, object: nil)
        let testError = NSError(domain: NSCocoaErrorDomain, code: 133020, userInfo: nil)
        
        // When
        sut.handleCoreDataError(testError)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHandleCoreDataError_WithContext() {
        // Given
        let testError = NSError(domain: NSCocoaErrorDomain, code: 134060, userInfo: nil)
        
        // When/Then
        sut.handleCoreDataError(testError, context: "Test Context")
        // Verify logging occurs - would need dependency injection for proper testing
    }
}
