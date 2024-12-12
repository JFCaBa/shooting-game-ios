//
//  DroneAnnotation.swift
//  ShootingApp
//
//  Created by Jose on 12/12/2024.
//

import MapKit

class DroneAnnotation: MKPointAnnotation {
    let droneId: String
    
    init(coordinate: CLLocationCoordinate2D, droneId: String) {
        self.droneId = droneId
        super.init()
        self.coordinate = coordinate
    }
}
