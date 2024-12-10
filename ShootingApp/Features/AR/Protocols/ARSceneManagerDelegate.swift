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
    func arSceneManager(_ manager: ARSceneManager, droneHitted drone: DroneData)
}

extension ARSceneManagerDelegate {
    func arSceneManager(_ manager: ARSceneManager, droneHitted drone: DroneData) {/*..*/}
}
