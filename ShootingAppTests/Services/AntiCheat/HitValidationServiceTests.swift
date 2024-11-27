//
//  HitValidationServiceTests.swift
//  ShootingAppTests
//
//  Created by Jose on 27/11/2024.
//

import XCTest
import CoreLocation
import AVFoundation
@testable import ShootingApp

final class HitValidationServiceTests: XCTestCase {
    var sut: HitValidationService!
    var mockAntiCheat: MockAntiCheatSystem!
    var mockLocationValidator: MockLocationValidationService!
    var mockPixelBuffer: CVPixelBuffer!
    
    override func setUp() {
        super.setUp()
        mockAntiCheat = MockAntiCheatSystem()
        mockLocationValidator = MockLocationValidationService()
        mockPixelBuffer = createMockPixelBuffer()
        sut = HitValidationService(
            antiCheatSystem: mockAntiCheat as! AntiCheatSystemProtocol,
            locationValidator: mockLocationValidator
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAntiCheat = nil
        mockLocationValidator = nil
        mockPixelBuffer = nil
        super.tearDown()
    }
    
    private func createMockPixelBuffer() -> CVPixelBuffer {
        let width = 64
        let height = 64
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            fatalError("Failed to create pixel buffer")
        }
        
        return buffer
    }
    
    func testValidHit_ReturnsSuccess() async throws {
        // Given
        let shooterLocation = CLLocation(latitude: 0, longitude: 0)
        let targetLocation = CLLocation(latitude: 0.001, longitude: 0.001)
        
        mockLocationValidator.validationToReturn = LocationValidation(
            isValid: true,
            distance: 10
        )
        
        mockAntiCheat.validationToReturn = ShotValidation(
            isValid: true,
            confidence: 0.9,
            timestamp: Date(),
            boundingBox: .zero
        )
        
        // When
        let result = try await sut.validateHit(
            shooterLocation: shooterLocation,
            targetLocation: targetLocation,
            pixelBuffer: mockPixelBuffer,
            tapLocation: .zero
        )
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidence, 0.9)
        XCTAssertEqual(result.distance, 10)
    }
    
    func testInvalidLocation_ThrowsError() async {
        // Given
        mockLocationValidator.validationToReturn = LocationValidation(
            isValid: false,
            distance: 100
        )
        
        // When/Then
        do {
            _ = try await sut.validateHit(
                shooterLocation: CLLocation(latitude: 0, longitude: 0),
                targetLocation: CLLocation(latitude: 1, longitude: 1),
                pixelBuffer: mockPixelBuffer,
                tapLocation: .zero
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? HitValidationError, .invalidDistance)
        }
    }
}
