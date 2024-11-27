//
//  CVPixelBuffer+Copy.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import CoreML

extension CVPixelBuffer {
    func copy() -> CVPixelBuffer {
        var copy: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            CVPixelBufferGetWidth(self),
            CVPixelBufferGetHeight(self),
            CVPixelBufferGetPixelFormatType(self),
            nil,
            &copy
        )
        
        guard let copiedBuffer = copy else {
            fatalError("Failed to create pixel buffer copy")
        }
        
        CVPixelBufferLockBaseAddress(self, .readOnly)
        CVPixelBufferLockBaseAddress(copiedBuffer, [])
        
        let srcData = CVPixelBufferGetBaseAddress(self)
        let destData = CVPixelBufferGetBaseAddress(copiedBuffer)
        let size = CVPixelBufferGetDataSize(self)
        
        memcpy(destData, srcData, size)
        
        CVPixelBufferUnlockBaseAddress(copiedBuffer, [])
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        
        return copiedBuffer
    }
}
