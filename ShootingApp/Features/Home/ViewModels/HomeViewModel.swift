//
//  HomeViewModel.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import CoreLocation

final class HomeViewModel {
    private let gameManager = GameManager.shared
    private var locationManager: CLLocationManager?
    
    func start() {
        setupLocation()
        gameManager.startGame()
    }
    
    func shoot() {
        guard let location = locationManager?.location else { return }
        
        let locationData = LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude,
            accuracy: location.horizontalAccuracy
        )
        
        gameManager.shoot(
            location: locationData,
            heading: locationManager?.heading?.trueHeading ?? 0
        )
    }
    
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
    }
    
    deinit {
        gameManager.endGame()
    }
}
