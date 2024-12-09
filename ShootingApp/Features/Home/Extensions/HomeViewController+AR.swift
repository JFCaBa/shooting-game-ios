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
            var message = ""
            switch reason {
            case .excessiveMotion:
                message = "Too much movement. Please slow down."
            case .insufficientFeatures:
                message = "Not enough detail in the environment."
            case .initializing:
                message = "AR is initializing."
            case .relocalizing:
                message = "AR relocalizing."
            @unknown default:
                message = "AR tracking limited."
            }
//            print(message)
        }
    }
    
    func arSceneManager(_ manager: ARSceneManager, didUpdateDroneCount count: Int) {
        updateDroneCount(count)
    }
}
