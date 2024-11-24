//
//  Notification+Names.swift
//  ShootingApp
//
//  Created by Jose on 27/10/2024.
//

import Foundation

extension Notification.Name {
    static let walletConnectionChanged = Notification.Name("WalletConnectionChanged")
    static let playerWasHit = Notification.Name("playerWasHit")
    static let playerHitTarget = Notification.Name("playerHitTarget")
    static let playerKilledTarget = Notification.Name("playerKilledTarget")
    static let playerDied = Notification.Name("playerDied")
    static let playerRespawned = Notification.Name("playerRespawned")
    static let connectionLost = Notification.Name("connectionLost")
}
