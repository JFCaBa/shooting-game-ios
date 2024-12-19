//
//  HomeViewController+Drones.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import Foundation

extension HomeViewController {
    // MARK: - updateDroneCount(_:)
    
    func updateDroneCount(_ count: Int) {
        if count > 0 {
            SoundManager.shared.playSound(type: .drone, loop: true)
        } else {
            SoundManager.shared.stopSound(type: .drone)
        }
        
        droneCount = count
        droneCountView.updateCount(count)
    }
    
    // MARK: - handleHitDroneConfirmation()
    
    @objc func handleHitDroneConfirmation(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let drone = userInfo["drone"] as? DroneData else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            showFeedback(.hit, amount: drone.reward ?? 2)
        }
    }
    
    // MARK: - handleKillConfirmation()
    
    @objc func handleKillConfirmation() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let gameScore = GameManager.shared.gameScore
            self.scoreView.updateScore(hits: gameScore.hits, kills: gameScore.kills)
            
            showFeedback(.kill, amount: amountKillReward)
        }
    }
}
