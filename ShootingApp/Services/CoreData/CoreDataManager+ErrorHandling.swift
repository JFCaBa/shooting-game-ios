//
//  CoreDataManager+ErrorHandling.swift
//  ShootingApp
//
//  Created by Jose on 24/11/2024.
//

import Foundation
import CoreData

extension CoreDataManager {
    func recreateContainer() {
        persistentContainer = NSPersistentContainer(name: "ShootingApp")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                ErrorHandlingService.shared.handleCoreDataError(error, context: "Recreating Container")
            }
        }
    }
    
    func saveContext(contextInfo: String = "") {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            ErrorHandlingService.shared.handleCoreDataError(error, context: contextInfo)
        }
    }
}
