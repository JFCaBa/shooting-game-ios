//
//  Double+DegreesToRadians.swift
//  ShootingApp
//
//  Created by Jose on 27/10/2024.
//

import Foundation

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
