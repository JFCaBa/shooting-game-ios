//
//  HomeViewController+Debug.swift
//  ShootingApp
//
//  Created by Jose on 28/11/2024.
//

import UIKit

extension HomeViewController {
    func setupDebugViews() {
        debugHitView = DebugView(frame: .zero)
        debugHitView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(debugHitView)
        
        NSLayoutConstraint.activate([
            debugHitView.centerXAnchor.constraint(equalTo: crosshairView.centerXAnchor),
            debugHitView.centerYAnchor.constraint(equalTo: crosshairView.centerYAnchor),
            debugHitView.widthAnchor.constraint(equalToConstant: 100),
            debugHitView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func showDebugHitMarker() {
        debugHitView.showFor()
    }
}
