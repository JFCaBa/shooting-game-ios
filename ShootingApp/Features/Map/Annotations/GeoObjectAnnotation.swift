//
//  GeoObjectAnnotation.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import MapKit

class GeoObjectAnnotation: MKPointAnnotation {
    let geoObject: GeoObject
    
    init(coordinate: CLLocationCoordinate2D, geoObject: GeoObject) {
        self.geoObject = geoObject
        super.init()
        self.coordinate = coordinate
    }
}
