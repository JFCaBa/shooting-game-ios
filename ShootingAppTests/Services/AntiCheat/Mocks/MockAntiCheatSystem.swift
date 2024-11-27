//
//  MockAntiCheatSystem.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import Foundation
import CoreML
import Vision

class MockAntiCheatSystem {
    var validationToReturn: ShotValidation?
    var errorToThrow: Error?
    
    func validateShot(with pixelBuffer: CVPixelBuffer, at location: CGPoint) async throws -> ShotValidation {
        if let error = errorToThrow {
            throw error
        }
        return validationToReturn ?? ShotValidation(
            isValid: false,
            confidence: 0,
            timestamp: Date(),
            boundingBox: .zero
        )
    }
}
