//
//  HitValidationSystem.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import CoreLocation
import AVFoundation

final class HitValidationService {
    private let antiCheatSystem: AntiCheatSystemProtocol
    private let locationValidator: LocationValidationService
    
    init(antiCheatSystem: AntiCheatSystemProtocol = AntiCheatSystem.shared,
         locationValidator: LocationValidationService = .shared) {
        self.antiCheatSystem = antiCheatSystem
        self.locationValidator = locationValidator
    }
    
    func validateHit(
        pixelBuffer: CVPixelBuffer,
        tapLocation: CGPoint
    ) async throws -> HitValidation {
        
        let visionValidation = try await antiCheatSystem.validateShot(
            with: pixelBuffer,
            at: tapLocation
        )
        
        guard visionValidation.isValid && visionValidation.isHighConfidence else {
            throw HitValidationError.targetNotDetected
        }
        
        return HitValidation(
            isValid: true,
            confidence: visionValidation.confidence,
            timestamp: Date()
        )
    }
}
