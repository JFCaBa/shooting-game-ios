//
//  SettingsViewModel.swift
//  ShootingApp
//
//  Created by Jose on 03/12/2024.
//

import Foundation

final class SettingsViewModel {
    // MARK: - Properties
    
    @Published private(set) var notificationDistance: Double
    weak var coordinator: AppCoordinator?
    
    // MARK: - Initialization
    
    init() {
        self.notificationDistance = UserDefaults.standard.double(forKey: UserDefaults.Keys.notificationDistance)
        if self.notificationDistance == 0 {
            self.notificationDistance = 100 // Default value
            UserDefaults.standard.set(self.notificationDistance, forKey: UserDefaults.Keys.notificationDistance)
        }
    }
    
    // MARK: - Public Methods
    
    func updateNotificationDistance(_ distance: Double) {
        notificationDistance = distance
        UserDefaults.standard.set(distance, forKey: UserDefaults.Keys.notificationDistance)
        NotificationCenter.default.post(name: .notificationDistanceChanged, object: nil)
    }
}
