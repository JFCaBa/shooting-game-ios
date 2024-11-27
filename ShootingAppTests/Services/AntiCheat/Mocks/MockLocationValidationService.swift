//
//  MockLocationValidationService.swift
//  ShootingApp
//
//  Created by Jose on 27/11/2024.
//

import CoreLocation

final class MockLocationValidationService: LocationValidationService {
    var validationToReturn: LocationValidation?
    
    override func validateLocations(shooter: CLLocation, target: CLLocation) -> LocationValidation {
        return validationToReturn ?? LocationValidation(isValid: false, distance: 0)
    }
}
