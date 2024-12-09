//
//  HitValidationError.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import Foundation

enum HitValidationError: Error {
    case noFrame
    case invalidDistance
    case noObservations
}
