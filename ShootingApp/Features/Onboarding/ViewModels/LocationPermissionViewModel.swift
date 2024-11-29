//
//  LocationPermissionViewModel.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import CoreLocation
import Combine

final class LocationPermissionViewModel: NSObject, OnboardingViewModelProtocol {
    weak var coordinator: OnboardingCoordinator?
    var permissionGranted = PassthroughSubject<Bool, Never>()
    private let locationManager: CLLocationManager
    
    init(coordinator: OnboardingCoordinator? = nil) {
        self.coordinator = coordinator
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func skip() {
        coordinator?.showPermissionsPage(.notifications)
    }
}

extension LocationPermissionViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            permissionGranted.send(true)
            coordinator?.showPermissionsPage(.notifications)
        case .denied, .restricted:
            permissionGranted.send(false)
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
