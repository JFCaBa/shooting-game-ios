//
//  PlayerEntity+CoreDataProperties.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreData

extension PlayerEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerEntity> {
        return NSFetchRequest<PlayerEntity>(entityName: "PlayerEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var accuracy: Double
    @NSManaged public var heading: Double
    @NSManaged public var lastUpdate: Date?
    
    // Convenience method to convert to domain model
    func toDomainModel() -> Player {
        return Player(
            playerId: id ?? "",
            location: LocationData(
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                accuracy: accuracy
            ),
            heading: heading
//            timestamp: lastUpdate ?? Date()
        )
    }
}

extension PlayerEntity : Identifiable {
}
