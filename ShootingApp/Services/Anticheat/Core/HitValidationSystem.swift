//
//  HitValidationSystem.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import CoreLocation
import ARKit

class HitValidationService {
    
    // MARK: - Properties
    
    private let humanDetector = VNDetectHumanRectanglesRequest()
    
    // MARK: - validateHit(sceneView:, tapLocation) -> HitValidation
    
    func validateHit(sceneView: ARSCNView?, tapLocation: CGPoint) async throws -> HitValidation {
        guard let frame = await sceneView?.session.currentFrame else {
            throw HitValidationError.noFrame
        }
        
        // Convert tap location to normalized coordinates
        let screenSize = await sceneView?.bounds.size ?? .zero
        let normalizedX = tapLocation.x / screenSize.width
        let normalizedY = tapLocation.y / screenSize.height
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        try requestHandler.perform([humanDetector])
        
        guard let observations = humanDetector.results else {
            throw HitValidationError.noObservations
        }
        
        for observation in observations {
            let boundingBox = observation.boundingBox
            if boundingBox.contains(CGPoint(x: normalizedX, y: normalizedY)) {
                // Calculate distance using ARKit depth data if available
                let distance = calculateDistance(frame: frame, at: tapLocation)
                return HitValidation(isValid: true, distance: distance)
            }
        }
        
        return HitValidation(isValid: false, distance: nil)
    }
    
    // MARK: - calculateDistance(frame:, at:) -> CGFloat
    
    func calculateDistance(frame: ARFrame, at point: CGPoint) -> CGFloat? {
        // Check if we have depth data
        guard let depthData = frame.estimatedDepthData else {
            return nil
        }
        
        // Lock buffer for reading
        CVPixelBufferLockBaseAddress(depthData, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(depthData, .readOnly)
        }
        
        let depthWidth = CVPixelBufferGetWidth(depthData)
        let depthHeight = CVPixelBufferGetHeight(depthData)
        
        // Convert tap point to depth map coordinates
        let x = Int((point.x / frame.camera.imageResolution.width) * CGFloat(depthWidth))
        let y = Int((point.y / frame.camera.imageResolution.height) * CGFloat(depthHeight))
        
        // Ensure coordinates are within bounds
        guard x >= 0, x < depthWidth, y >= 0, y < depthHeight else {
            return nil
        }
        
        // Get depth value for this point
        let depthBytesPerRow = CVPixelBufferGetBytesPerRow(depthData)
        let depthDataPtr = CVPixelBufferGetBaseAddress(depthData)!
        let depthPtr = depthDataPtr.advanced(by: y * depthBytesPerRow + x * MemoryLayout<Float32>.size)
            .assumingMemoryBound(to: Float32.self)
        
        return CGFloat(depthPtr.pointee)
    }
}
