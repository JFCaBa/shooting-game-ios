//
//  CameraPermissionViewModel.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import AVFoundation
import Combine

final class CameraPermissionViewModel: BaseOnboardingViewModel {
    override init(coordinator: OnboardingCoordinator? = nil) {
        super.init(coordinator: coordinator)
    }
    
    override func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            self?.permissionGranted.send(granted)
        }
    }
    
    override func skip() {
        coordinator?.showPermissionsPage(.location)
    }
}
