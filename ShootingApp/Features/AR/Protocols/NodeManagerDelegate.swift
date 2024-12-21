//
//  NodeManagerDelegate.swift
//  ShootingApp
//
//  Created by Jose on 20/12/2024.
//

import Foundation

protocol NodeManagerDelegate: AnyObject {
    func nodeManagerDidUpdateDroneCount(_ manager: any NodeManager, count: Int)
    func nodeManagerDidUpdateGeoObjectCount(_ manager: any NodeManager, count: Int)
    func nodeManager(_ manager: any NodeManager, droneHit drone: DroneData)
    func nodeManager(_ manager: any NodeManager, geoObjectHit object: GeoObject)
}

extension NodeManagerDelegate {
    func nodeManagerDidUpdateDroneCount(_ manager: any NodeManager, count: Int) {}
    func nodeManagerDidUpdateGeoObjectCount(_ manager: any NodeManager, count: Int) {}
    func nodeManager(_ manager: any NodeManager, droneHit drone: DroneData) {}
    func nodeManager(_ manager: any NodeManager, geoObjectHit object: GeoObject) {}
}
