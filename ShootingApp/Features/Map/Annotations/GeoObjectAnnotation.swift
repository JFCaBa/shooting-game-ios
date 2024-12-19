//
//  GeoObjectAnnotation.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import MapKit

class GeoObjectAnnotation: MKPointAnnotation {
    let geoObjectId: String
    
    init(coordinate: CLLocationCoordinate2D, geoObjectId: String) {
        self.geoObjectId = geoObjectId
        super.init()
        self.coordinate = coordinate
    }
}
