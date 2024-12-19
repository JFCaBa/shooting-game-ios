//
//  MapViewController+LocationDelegate.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import CoreLocation
import MapKit

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 1000/111000, longitudeDelta: 1000/111000)
        )
        mapView.setRegion(region, animated: true)
        
        // Once we've zoomed to the location, we can stop updating
        locationManager.stopUpdatingLocation()
    }
}
