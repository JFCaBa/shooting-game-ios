//
//  NotificationsPermissionViewModel.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import UserNotifications
import Combine

final class NotificationsPermissionViewModel: BaseOnboardingViewModel {
    override init(coordinator: OnboardingCoordinator? = nil) {
        super.init(coordinator: coordinator)
    }
    
    override func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
            self?.permissionGranted.send(granted)
        }
    }
    
    override func skip() {
        coordinator?.showPermissionsPage(.wallet)
    }
}
