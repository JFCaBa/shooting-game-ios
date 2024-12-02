//
//  CoreDataManager.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()
    public var persistentContainer: NSPersistentContainer

    
    // Default initializer using AppDelegate's persistentContainer
    private init(persistentContainer: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    
    func createOrUpdatePlayer(from player: Player) {
        let fetchRequest: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", player.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            let playerEntity: PlayerEntity
            
            if let existingPlayer = results.first {
                playerEntity = existingPlayer
            } else {
                playerEntity = PlayerEntity(context: context)
                playerEntity.id = player.id
            }
            
            // Update properties
            playerEntity.latitude = player.location.latitude
            playerEntity.longitude = player.location.longitude
            playerEntity.altitude = player.location.altitude
            playerEntity.accuracy = player.location.accuracy
            playerEntity.heading = player.heading
            playerEntity.lastUpdate = .now
            
            saveContext()
        } catch {
            print("Error fetching/saving player: \(error)")
        }
    }
    
    func getStoredPlayers() -> [Player] {
        let fetchRequest: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { entity in
                Player(
                    id: entity.id ?? "",
                    location: LocationData(
                        latitude: entity.latitude,
                        longitude: entity.longitude,
                        altitude: entity.altitude,
                        accuracy: entity.accuracy
                    ),
                    heading: entity.heading
//                    timestamp: entity.lastUpdate ?? Date()
                )
            }
        } catch {
            print("Error fetching players: \(error)")
            return []
        }
    }
    
    func deletePlayer(id: String) {
        let fetchRequest: NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Error deleting player: \(error)")
        }
    }
    
    func deleteAllPlayers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PlayerEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
            saveContext()
        } catch {
            print("Error deleting all players: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
