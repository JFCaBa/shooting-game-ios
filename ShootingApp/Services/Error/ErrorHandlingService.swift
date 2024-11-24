//
//  ErrorHandlingService.swift
//  ShootingApp
//
//  Created by Jose on 24/11/2024.
//

import Foundation
import CoreData

final class ErrorHandlingService {
    static let shared = ErrorHandlingService()
    
    private init() {}
    
    func handleCoreDataError(_ error: Error, context: String = "") {
        let nsError = error as NSError
        
        #if DEBUG
        print("CoreData Error: \(nsError), \(nsError.userInfo)")
        print("Context: \(context)")
        #endif
        
        switch nsError.domain {
        case NSCocoaErrorDomain:
            handleCocoaError(nsError)
        default:
            handleGenericError(nsError)
        }
        
        NotificationCenter.default.post(
            name: .coreDataErrorOccurred,
            object: nil,
            userInfo: ["error": error]
        )
    }
    
    private func handleCocoaError(_ error: NSError) {
        switch error.code {
        case 133020: // NSManagedObjectValidationError
            handleValidationError(error)
        case 134060: // NSPersistentStoreSaveError
            handlePersistentStoreError(error)
        case 134110: // NSMigrationError
            handleMigrationError(error)
        default:
            handleGenericError(error)
        }
    }
    
    private func handleValidationError(_ error: NSError) {
        guard let details = error.userInfo["NSValidationErrorKey"] else { return }
        print("Validation Error: \(details)")
    }
    
    private func handlePersistentStoreError(_ error: NSError) {
        print("Persistent Store Error: \(error.localizedDescription)")
        // Implement recovery strategy
        attemptStoreRecovery()
    }
    
    private func handleMigrationError(_ error: NSError) {
        print("Migration Error: \(error.localizedDescription)")
        // Implement migration error handling
    }
    
    private func handleGenericError(_ error: NSError) {
        print("Generic CoreData Error: \(error.localizedDescription)")
    }
    
    private func attemptStoreRecovery() {
        // Implement store recovery logic
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let storeURL = documentsPath.appendingPathComponent("ShootingApp.sqlite")
        
        do {
            try fileManager.removeItem(at: storeURL)
            // Recreate store
            CoreDataManager.shared.recreateContainer()
        } catch {
            print("Failed to recover store: \(error)")
        }
    }
}
