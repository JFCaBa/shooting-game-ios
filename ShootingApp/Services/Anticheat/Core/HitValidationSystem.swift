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
    
    private func calculateDistance(frame: ARFrame, at point: CGPoint) -> CGFloat? {
        // Check if the scene depth is available
        guard let sceneDepth = frame.sceneDepth else {
            return nil
        }
        
        // Get the depth map from the ARFrame
        let depthData = sceneDepth.depthMap
        let depthWidth = CVPixelBufferGetWidth(depthData)
        let depthHeight = CVPixelBufferGetHeight(depthData)
        
        // Lock the pixel buffer for reading
        CVPixelBufferLockBaseAddress(depthData, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthData, .readOnly) }
        
        // Get the pointer to the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(depthData)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthData)
        
        // Convert the tap location (in screen space) to the depth map coordinates
        let screenSize = frame.camera.imageResolution
        let xDepth = Int((point.x / screenSize.width) * CGFloat(depthWidth))
        let yDepth = Int((point.y / screenSize.height) * CGFloat(depthHeight))
        
        // Ensure the coordinates are within bounds
        guard xDepth >= 0 && xDepth < depthWidth && yDepth >= 0 && yDepth < depthHeight else {
            return nil
        }
        
        // Extract the depth value at the given coordinates
        let depthPointer = baseAddress!.advanced(by: yDepth * bytesPerRow + xDepth * MemoryLayout<Float32>.size)
        let depthValue = depthPointer.assumingMemoryBound(to: Float32.self).pointee
        
        return CGFloat(depthValue) // Convert to CGFloat to match the return type
    }
}
