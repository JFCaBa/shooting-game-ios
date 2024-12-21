//
//  ARContainerView.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import ARKit
import UIKit

final class ARContainerView: UIView {
    // MARK: - Properties
    
    let sceneView: ARSCNView
    let manager: ARSceneManager
    
    // MARK: - Closures
    
    var onHit: ((Bool) -> Void)?
    
    // MARK: - init(frame:)
    
    override init(frame: CGRect) {
        sceneView = ARSCNView(frame: .zero)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = .clear
        sceneView.isOpaque = false
        
        manager = ARSceneManager(sceneView: sceneView)
        
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        backgroundColor = .clear
        isOpaque = false
        
        addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func getDrones() -> [DroneData] {
        return manager.getDrones()
    }
    
    func getGeoObjects() -> [GeoObject] {
        return manager.getGeoObjects()
    }
    
    func checkHit(at point: CGPoint) -> Bool {
        let hit = manager.checkHit(at: point)
        onHit?(hit)
        return hit
    }
    
    func stop() {
        manager.stop()
    }
    
    func updateZoom(scale: CGFloat) {
         manager.updateZoom(scale: scale)
    }
}
