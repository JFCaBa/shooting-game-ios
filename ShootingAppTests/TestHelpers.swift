//
//  TestHelpers.swift
//  ShootingAppTests
//
//  Created by Jose on 23/11/2024.
//

import Foundation
@testable import ShootingApp
import XCTest

extension Web3Service {
    static func resetSharedInstance() {
        // Helper method to reset singleton state between tests if needed
    }
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
