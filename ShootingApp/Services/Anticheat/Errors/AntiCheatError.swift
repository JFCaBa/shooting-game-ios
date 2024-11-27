//
//  AntiCheatError.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import Foundation

enum AntiCheatError: Error {
    case systemNotInitialized
    case noObservations
    case noPersonDetected
    case shotTooFast
}
