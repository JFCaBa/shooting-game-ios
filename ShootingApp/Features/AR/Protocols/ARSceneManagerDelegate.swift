//
//  ARSceneManagerDelegate.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import ARKit

protocol ARSceneManagerDelegate: AnyObject {
    func arSceneManager(_ manager: ARSceneManager, didUpdateTrackingState state: ARCamera.TrackingState)
    func arSceneManager(_ manager: ARSceneManager, didUpdateDroneCount count: Int)
    func arSceneManager(_ manager: ARSceneManager, didUpdateGeoObjectCount count: Int)
    func arSceneManager(_ manager: ARSceneManager, droneHit drone: DroneData)
    func arSceneManager(_ manager: ARSceneManager, geoObjectHit object: GeoObject)
}

// Default implementations
extension ARSceneManagerDelegate {
    func arSceneManager(_ manager: ARSceneManager, didUpdateGeoObjectCount count: Int) {}
    func arSceneManager(_ manager: ARSceneManager, geoObjectHit object: GeoObject) {}
}
