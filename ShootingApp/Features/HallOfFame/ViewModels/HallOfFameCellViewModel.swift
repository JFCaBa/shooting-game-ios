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
        let name = element.nickName != nil ? element.nickName : "\(element.playerID?.suffix(4) ?? "Unknown")"
        return name ?? "Unknown"
    }
    
    var score: String {
        "\(element.stats.kills) kills, \(element.stats.hits) hits, \(element.stats.droneHits ?? 0) drones"
    }
    
    var backgroundColor: UIColor {
        isPlayer ? .customPlaygroundQuickLook: .secondarySystemFill
    }
    
    var isPlayer: Bool {
        return element.playerID == GameManager.shared.playerId
    }
}
