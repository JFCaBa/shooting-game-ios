//
//  HomeViewController+GeoObject.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import UIKit

extension HomeViewController {
    func updateGeoObjectCount(_ count: Int) {

    }
    
    // MARK: - handleGeoObjectHit(_:)

    @objc func handleGeoObjectHit(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let geoObject = userInfo["geoObject"] as? GeoObject else { return }
        
        // Play hit sound effect
        SoundManager.shared.playSound(type: .hit)
        
        // Show visual feedback
        showFeedback(.reward, amount: geoObject.metadata.reward ?? 1)
    }
    
    // MARK: - handleGeoObectShootConfirmed(_:)
    
    @objc func handleGeoObjectShootConfirmed(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let geoObject = userInfo["geoObject"] as? GeoObject
        else { return }
        
        // Update game score
        let gameScore = GameManager.shared.gameScore
        self.scoreView.updateScore(hits: gameScore.hits, kills: gameScore.kills)
        
        // Show reward feedback
        showFeedback(.custom(
            text: "GEO REWARD",
            color: .systemPurple,
            font: .systemFont(ofSize: 32, weight: .bold)
        ), amount: geoObject.metadata.reward ?? 1)
        
        radarView.removeTarget(id: geoObject.id)
    }
    
    // MARK: - handleNewGeoObjectArrived(_:)
    
    @objc func handleNewGeoObjectArrived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let geoObjects = userInfo["geoObject"] as? [GeoObject]
        else { return }
        
        geoObjects.forEach { geoObject in
            radarView.addTarget(geoObject)
        }
        
        // Optional: Play sound for new geo object
        SoundManager.shared.playSound(type: .spawn)
    }
}
