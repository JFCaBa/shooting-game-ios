//
//  HallOfFameCellViewModel.swift
//  ShootingApp
//
//  Created by Jose on 08/12/2024.
//

import UIKit

struct HallOfFameCellViewModel {
    var elements: HallOfFameResponse!
    var row: Int!
    
    var element: HallOfFameResponseElement {
        elements[row]
    }
    
    var rank: String {
        return "\(row + 1)"
    }
    
    var name: String {
        return "\(element.playerID?.suffix(4) ?? "Unknown")"
    }
    
    var score: String {
        "\(element.stats.kills) kills, \(element.stats.hits) players hits, \(element.stats.droneHits ?? 0)drone hits"
    }
    
    var backgroundColor: UIColor {
        isPlayer ? .customPlaygroundQuickLook: .secondarySystemFill
    }
    
    var isPlayer: Bool {
        return element.playerID == GameManager.shared.playerId
    }
}
