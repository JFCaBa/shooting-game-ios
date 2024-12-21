//
//  HomeViewController+AR.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import ARKit
import UIKit

extension HomeViewController: ARSceneManagerDelegate {
    func setupAR() {
        let arView = ARContainerView(frame: .zero)
        arView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set delegate
        arView.manager.delegate = self
        
        // Insert AR view just above the camera preview but below all UI elements
        view.insertSubview(arView, at: 1)
        
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Register AR view with service after setup
        ARService.shared.registerARView(arView)
    }
    
    func arSceneManager(_ manager: ARSceneManager, didUpdateTrackingState state: ARCamera.TrackingState) {
        switch state {
        case .normal:
            break
        case .notAvailable:
            // TODO: add a delegate to not use AR
            break
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                break;
            case .insufficientFeatures:
                break;
            case .initializing:
                break;
            case .relocalizing:
                break;
            @unknown default:
                break;
            }
        }
    }
    
    func arSceneManager(_ manager: ARSceneManager, didUpdateDroneCount count: Int) {
        updateDroneCount(count)
    }
    
    func arSceneManager(_ manager: ARSceneManager, droneHit drone: DroneData) {
        viewModel.shoot(at: nil, drone: drone)
    }
    
    func arSceneManager(_ manager: ARSceneManager, didUpdateGeoObjectCount count: Int) {
        radarView.isHidden = count == 0
    }
    
    func arSceneManager(_ manager: ARSceneManager, geoObjectHit object: GeoObject) {
        radarView.removeTarget(id: object.id)
        radarView.isHidden = radarView.numberOfTargets() == 0
        viewModel.shoot(at: nil, geoObject: object)
    }
}
