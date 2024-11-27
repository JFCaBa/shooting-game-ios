//
//  AntiCheatSystemProtocol.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import AVFoundation
import CoreGraphics

protocol AntiCheatSystemProtocol {
    func validateShot(with pixelBuffer: CVPixelBuffer, at location: CGPoint) async throws -> ShotValidation
}

extension AntiCheatSystem: AntiCheatSystemProtocol {}
