//
//  AntiCheatSystem.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import Vision
import AVFoundation
import CoreML

class AntiCheatSystem {
    static let shared = AntiCheatSystem()
    
    private let visionQueue = DispatchQueue(label: "com.shootingapp.vision")
    private var personDetectionRequest: VNDetectHumanRectanglesRequest?
    private var lastValidatedTimestamp: Date = .distantPast
    private let minimumTimeBetweenShots: TimeInterval = 1.0
    
    weak var debugDelegate: AntiCheatDebugDelegate?
    
    private init() {
        setupVisionRequest()
    }
    
    private func setupVisionRequest() {
        personDetectionRequest = VNDetectHumanRectanglesRequest()
    }
    
    func validateShot(with pixelBuffer: CVPixelBuffer, at location: CGPoint) async throws -> ShotValidation {
        guard Date().timeIntervalSince(lastValidatedTimestamp) >= minimumTimeBetweenShots else {
            throw AntiCheatError.shotTooFast
        }
        
        return try await detectPerson(in: pixelBuffer, at: location)
    }
    
    private func detectPerson(in pixelBuffer: CVPixelBuffer, at location: CGPoint) async throws -> ShotValidation {
        guard let request = personDetectionRequest else {
            throw AntiCheatError.systemNotInitialized
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try handler.perform([request])
        
        guard let observations = request.results,
              !observations.isEmpty else {
            throw AntiCheatError.noObservations
        }
        
        let normalizedLocation = CGPoint(
            x: location.x,
            y: 1 - location.y
        )
        
        for observation in observations {
            if observation.boundingBox.contains(normalizedLocation) {
                lastValidatedTimestamp = Date()
#if DEBUG
                debugDelegate?.showDebugRect(observation.boundingBox)
#endif
                return ShotValidation(
                    isValid: true,
                    confidence: observation.confidence,
                    timestamp: Date(),
                    boundingBox: observation.boundingBox
                )
            }
        }
        
        throw AntiCheatError.noPersonDetected
    }
}
