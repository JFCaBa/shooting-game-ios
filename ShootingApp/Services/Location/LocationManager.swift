//
//  LocationManager.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import CoreLocation
import UIKit

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    private var locationManager: CLLocationManager
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var backgroundTimer: Timer?
    private let maxBackgroundTime: TimeInterval = 600 // 10 minutes
    
    private var currentLocation: CLLocation?
    private var currentHeading: CLHeading?
    
    var location: CLLocation? {
        return currentLocation
    }
    
    var heading: CLHeading? {
        return currentHeading
    }
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
        startLocationUpdates()
        setupNotifications()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleBackground() {
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: maxBackgroundTime, repeats: false) { [weak self] _ in
            self?.stopLocationUpdates()
        }
    }
    
    @objc private func handleForeground() {
        backgroundTimer?.invalidate()
        backgroundTimer = nil
        
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        
        startLocationUpdates()
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    func distanceFrom(latitude: Double, longitude: Double) -> Double {
        guard let location else { return Double(MAXFLOAT) }
        
        let fromLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: fromLocation)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            startLocationUpdates()
        case .authorizedWhenInUse, .denied, .restricted:
            stopLocationUpdates()
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        NotificationCenter.default.post(
            name: .locationDidUpdate,
            object: nil,
            userInfo: ["location": locations.last as Any]
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading
        NotificationCenter.default.post(
            name: .headingDidUpdate,
            object: nil,
            userInfo: ["heading": newHeading]
        )
    }
}
