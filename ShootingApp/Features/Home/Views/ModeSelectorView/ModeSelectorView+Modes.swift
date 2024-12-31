//
//  ModeSelectorView+Modes.swift
//  ShootingApp
//
//  Created by Jose on 29/12/2024.
//

import Foundation

extension ModeSelectorView {
    enum Mode: String, CaseIterable {
        case inventory = "INVENTORY"
        case map = "MAP"
        case game = "GAME"
        case achievements = "ACHIEVEMENTS"
        case hallOfFame = "HALL OF FAME"
        case wallet = "WALLET"
        
        static let modes: [Mode] = [.inventory, .map, .game, .achievements, .hallOfFame, .wallet]
    }
}
