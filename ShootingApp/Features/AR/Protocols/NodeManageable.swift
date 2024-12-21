//
//  NodeManageable.swift
//  ShootingApp
//
//  Created by Jose on 20/12/2024.
//

import Foundation

protocol NodeManageable {
    var nodeId: String? { get }
    func wasHit() -> Bool
    func cleanupNode()
}
