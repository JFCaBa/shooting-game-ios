//
//  GameManagerProtocol.swift
//  ShootingApp
//
//  Created by Jose on 24/11/2024.
//

import Foundation

protocol GameManagerProtocol {
    var currentLives: Int { get }
    var isAlive: Bool { get }
    var gameScore: GameScore { get }
    var playerId: String? { get }
    func shoot(at: CGPoint?, drone: DroneData?, geoObject: GeoObject?, location: LocationData, heading: Double)
    func startGame()
    func endGame()
}
