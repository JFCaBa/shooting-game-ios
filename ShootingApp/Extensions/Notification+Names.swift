//
//  Notification+Names.swift
//  ShootingApp
//
//  Created by Jose on 27/10/2024.
//

import Foundation

extension Notification.Name {
    static let walletConnectionChanged = Notification.Name("WalletConnectionChanged")
    static let metamaskDidConnect = Notification.Name("MetamaskDidConnect")
    static let playerWasHit = Notification.Name("playerWasHit")
    static let playerHitTarget = Notification.Name("playerHitTarget")
    static let playerKilledTarget = Notification.Name("playerKilledTarget")
    static let shootConfirmed = Notification.Name("shootConfirmed")
    static let dronShootConfirmed = Notification.Name("dronShootConfirmed")
    static let playerDied = Notification.Name("playerDied")
    static let playerRespawned = Notification.Name("playerRespawned")
    static let connectionLost = Notification.Name("connectionLost")
    static let coreDataErrorOccurred = Notification.Name("CoreDataErrorOccurred")
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
    static let locationDidUpdate = Notification.Name("locationDidUpdate")
    static let headingDidUpdate = Notification.Name("headingDidUpdate")
    static let playerJoined = Notification.Name("playerJoined")
    static let notificationDistanceChanged = Notification.Name("notificationDistanceChanged")
    static let websocketStatusChanged = Notification.Name("websocketStatusChanged")
    static let newDroneArrived = Notification.Name("newDroneArrived")

}
