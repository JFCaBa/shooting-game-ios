//
//  QueueManager.swift
//  ShootingApp
//
//  Created by Jose on 27/10/2024.
//

import Foundation

final class DispatchQueueManager {
    static let shared = DispatchQueueManager()
    
    private let coreDataQueue = DispatchQueue(label: "com.shootingapp.coredata", qos: .userInitiated)
    
    private init() {}
    
    func performOnMainThread(_ operation: @escaping () -> Void) {
        if Thread.isMainThread {
            operation()
        } else {
            DispatchQueue.main.async(execute: operation)
        }
    }
    
    func performCoreDataOperation(_ operation: @escaping () -> Void) {
        coreDataQueue.async(execute: operation)
    }
}
