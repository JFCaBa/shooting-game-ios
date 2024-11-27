//
//  AntiCheatSystemTest.swift
//  ShootingAppTests
//
//  Created by Jose on 27/11/2024.
//

import XCTest
import Vision
import AVFoundation
@testable import ShootingApp

final class AntiCheatSystemTests: XCTestCase {
    var sut: AntiCheatSystem!
    var mockPixelBuffer: CVPixelBuffer!
    
    override func setUp() {
        super.setUp()
        sut = AntiCheatSystem.shared
        mockPixelBuffer = createMockPixelBuffer()
    }
    
    override func tearDown() {
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
    
    func testValidateShot_TooFast_ThrowsError() async {
        // Given
        let tapLocation = CGPoint(x: 0.5, y: 0.5)
        
        // When/Then
        do {
            _ = try await sut.validateShot(with: mockPixelBuffer, at: tapLocation)
            _ = try await sut.validateShot(with: mockPixelBuffer, at: tapLocation)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? AntiCheatError, .shotTooFast)
        }
    }
    
    func testValidateShot_NoObservations_ThrowsError() async {
        // Given
        let tapLocation = CGPoint(x: 0.5, y: 0.5)
        
        // When/Then
        do {
            _ = try await sut.validateShot(with: mockPixelBuffer, at: tapLocation)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? AntiCheatError, .noObservations)
        }
    }
    
    func testValidateShot_OutsidePersonBounds_ThrowsError() async {
        // Given
        let tapLocation = CGPoint(x: 1.5, y: 1.5) // Outside normalized bounds
        
        // When/Then
        do {
            _ = try await sut.validateShot(with: mockPixelBuffer, at: tapLocation)
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? AntiCheatError, .noPersonDetected)
        }
    }
}
