//
//  PlayerManager.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreData

final class PlayerManagerService {
    static let shared = PlayerManagerService()
    private let coreDataManager = CoreDataManager.shared
    private let stalePlayerTimeout: TimeInterval = 300 // 5 minutes
    private var heartbeatTimer: Timer?
    
    private init() {
        startHeartbeat()
    }
    
    deinit {
        stopHeartbeat()
    }
    
    func startHeartbeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.removeStaleUsers()
        }
    }
    
    func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    func updatePlayer(_ player: Player) {
        coreDataManager.createOrUpdatePlayer(from: player)
        removeStaleUsers()
    }
    
    private func removeStaleUsers() {
        let context = coreDataManager.context
        let fetchRequest: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        let staleDate = Date().addingTimeInterval(-stalePlayerTimeout)
        fetchRequest.predicate = NSPredicate(format: "lastUpdate < %@", staleDate as CVarArg)
        
        do {
            let stalePlayers = try context.fetch(fetchRequest)
            
            guard !stalePlayers.isEmpty else { return }
            
            stalePlayers.forEach { player in
                print("Removing stale player: \(player.id ?? "unknown")")
                context.delete(player)
            }
            
            coreDataManager.saveContext()
            
            // Notify about players removal
            NotificationCenter.default.post(
                name: NSNotification.Name("PlayersUpdated"),
                object: nil
            )
        } catch {
            print("Error removing stale players: \(error)")
        }
    }
}
