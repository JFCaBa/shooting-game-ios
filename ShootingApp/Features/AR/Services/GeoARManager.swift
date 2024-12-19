//
//  GeoARManager.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import ARKit
import CoreLocation

final class GeoARManager: NSObject {
    // MARK: - Properties
    
    private let sceneView: ARSCNView
    private let locationManager = LocationManager.shared
    private var geoNodes: [GeoARNode] = []
    
    // MARK: - Init
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        super.init()
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocationUpdate),
            name: .locationDidUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHeadingUpdate),
            name: .headingDidUpdate,
            object: nil
        )
    }
    
    // MARK: - Node Management
    
    func addNode(_ node: GeoARNode) {
        geoNodes.append(node)
        sceneView.scene.rootNode.addChildNode(node)
        updateNodePositions()
    }
    
    func removeNode(_ node: GeoARNode) {
        node.removeFromParentNode()
        geoNodes.removeAll { $0 === node }
    }
    
    func removeAllNodes() {
        geoNodes.forEach { $0.removeFromParentNode() }
        geoNodes.removeAll()
    }
    
    // MARK: - Updates
    
    @objc private func handleLocationUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let location = userInfo["location"] as? CLLocation else { return }
        updateNodePositions(location: location)
    }
    
    @objc private func handleHeadingUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let heading = userInfo["heading"] as? CLHeading else { return }
        updateNodePositions(heading: heading)
    }
    
    private func updateNodePositions(location: CLLocation? = nil, heading: CLHeading? = nil) {
        let userLocation = location ?? locationManager.location
        let userHeading = heading ?? locationManager.heading
        
        guard let userLocation else { return }
        
        for node in geoNodes {
            node.updatePosition(relativeTo: userLocation, heading: userHeading)
        }
    }
}
