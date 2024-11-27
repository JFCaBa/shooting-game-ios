//
//  LocationValidationSystem.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import CoreLocation

class LocationValidationService {
    static let shared = LocationValidationService()
    
    private let maxShootingDistance: CLLocationDistance = 50
    private let minShootingDistance: CLLocationDistance = 2
    private let maxAngleError: Double = 30
    
    func validateLocations(shooter: CLLocation, target: CLLocation) -> LocationValidation {
        let distance = shooter.distance(from: target)
        
        guard distance <= maxShootingDistance && distance >= minShootingDistance else {
            return LocationValidation(isValid: false, distance: distance)
        }
        
        return LocationValidation(isValid: true, distance: distance)
    }
}
