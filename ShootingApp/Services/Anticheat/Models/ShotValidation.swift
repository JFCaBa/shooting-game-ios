//
//  ShotValidation.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import Vision

struct ShotValidation {
    let isValid: Bool
    let confidence: Float
    let timestamp: Date
    let boundingBox: CGRect
    
    var isHighConfidence: Bool {
        confidence > 0.8
    }
}
