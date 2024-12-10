//
//  ARSceneManager.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import ARKit
import Combine
import SceneKit

final class ARSceneManager: NSObject {
    
    // MARK: - Properties
    
    private let sceneView: ARSCNView
    private var droneNodes: [ARDroneNode] = []
    private var timer: Timer?
    private let maxDrones = 3
    private let spawnInterval: TimeInterval = 10.0
    private var lastSpawnPosition: SCNVector3?
    private let minimumDroneSpacing: Float = 20  // Minimum distance between drones
    private var currentZoom: Float = 1.0
    
    weak var delegate: ARSceneManagerDelegate?
    
    // MARK: - init(sceneView:)
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        super.init()
        setupScene()
        setupObservers()
    }
    
    // MARK: - setupScene()
    private func setupScene() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene = SCNScene()
        
        // Run AR session setup on background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let configuration = ARWorldTrackingConfiguration()
            
            DispatchQueue.main.async {
                self?.sceneView.session.run(configuration)
            }
        }
    }
    
    // MARK: - setupObservers()
    
    func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewDroneArrived),
            name: .newDroneArrived,
            object: nil)
    }
    
    // MARK: - handleNewDroneArrived(notification:)
    
    @objc private func handleNewDroneArrived(notification: Notification) {
        guard let userInfo = notification.userInfo,
                  let drone = userInfo["drone"] as? DroneData else { return }
        
        DispatchQueue.main.async {
            self.spawnDroneIfNeeded(drone: drone)
        }
    }
    
    // MARK: - spawnDroneIfNeeded()
    
    private func spawnDroneIfNeeded(drone: DroneData) {
        guard droneNodes.count < maxDrones else { return }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            self.droneNodes = self.droneNodes.filter { $0.parent != nil }
            
            let position = self.generateSpawnPosition(drone: drone)
            let drone = ARDroneNode()
            drone.position = position
            
            DispatchQueue.main.async {
                self.sceneView.scene.rootNode.addChildNode(drone)
                self.droneNodes.append(drone)
                self.delegate?.arSceneManager(self, didUpdateDroneCount: self.droneNodes.count)
                self.lastSpawnPosition = position
            }
        }
    }
    
    // MARK: - generateSpawnPosition()
    
    private func generateSpawnPosition(drone: DroneData) -> SCNVector3 {
        var newPosition: SCNVector3
        
        newPosition = SCNVector3(
            x: drone.position.x,
            y: drone.position.y,
            z: drone.position.z
        )
        
        return newPosition
    }
    
    // MARK: - checkHit(at:)
    
    func checkHit(at point: CGPoint) -> Bool {
        let hitResults = sceneView.hitTest(point, options: [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.ignoreChildNodes: false
        ])
        
        for result in hitResults {
            if let droneNode = result.node.parent as? ARDroneNode {
                let hit = droneNode.hit()
                if hit {
                    droneNodes.removeAll { $0 == droneNode }
                    DispatchQueue.main.async {
                        self.delegate?.arSceneManager(self, didUpdateDroneCount: self.droneNodes.count)
                    }
                }
                return hit
            }
        }
        
        return false
    }
    
    // MARK: - stop()
    
    func stop() {
        timer?.invalidate()
        timer = nil
        sceneView.session.pause()
    }
    
    // MARK: - updateZoom(scale:)
    
    func updateZoom(scale: CGFloat) {
        currentZoom = Float(scale)
        if let camera = sceneView.pointOfView?.camera {
            let fov = 60.0 / Double(scale)
            camera.fieldOfView = CGFloat(fov)
            
            // Update camera position for zoom effect
//            let zoomDirection = SCNVector3(0, 0, -1) // Forward direction
            let zoomDistance = 1.0 - (1.0 / Double(scale)) // Calculate zoom distance
            sceneView.pointOfView?.position = SCNVector3(0, 0, Float(zoomDistance))
        }
    }
}

// MARK: - Delegates

extension ARSceneManager: ARSCNViewDelegate, ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        delegate?.arSceneManager(self, didUpdateTrackingState: frame.camera.trackingState)
    }
}
