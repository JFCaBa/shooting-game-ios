//
//  HitValidationError.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import Foundation

enum HitValidationError: Error {
    case invalidDistance
    case targetNotDetected
    case invalidAngle
}
