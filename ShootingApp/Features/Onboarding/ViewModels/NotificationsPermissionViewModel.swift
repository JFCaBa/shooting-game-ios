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
        NotificationManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async { 
                self.permissionGranted.send(granted)
            }
        }
    }
    
    override func skip() {
        coordinator?.finishOnboarding()
    }
}
