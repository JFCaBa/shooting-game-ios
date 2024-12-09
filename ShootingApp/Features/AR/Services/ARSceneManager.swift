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
    private let minimumDroneSpacing: Float = 5  // Minimum distance between drones
    
    weak var delegate: ARSceneManagerDelegate?
    
    // MARK: - init(sceneView:)
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        super.init()
        setupScene()
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
                self?.startSpawningDrones()
            }
        }
    }
    
    // MARK: - startSpawingDrones()
    
    private func startSpawningDrones() {
        // Create timer on main queue
        DispatchQueue.main.async { [weak self] in
            self?.timer = Timer.scheduledTimer(withTimeInterval: self?.spawnInterval ?? 10.0, repeats: true) { [weak self] _ in
                self?.spawnDroneIfNeeded()
            }
        }
    }
    
    // MARK: - spawnDroneIfNeeded()
    
    private func spawnDroneIfNeeded() {
        guard droneNodes.count < maxDrones else { return }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            self.droneNodes = self.droneNodes.filter { $0.parent != nil }
            
            let position = self.generateSpawnPosition()
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
    
    private func generateSpawnPosition() -> SCNVector3 {
        var attempts = 0
        var newPosition: SCNVector3
        
        repeat {
            newPosition = SCNVector3(
                x: Float.random(in: -3...3),
                y: Float.random(in: 4...6),
                z: Float.random(in: -5...5)
            )
            attempts += 1
        } while isTooCloseToOtherDrones(position: newPosition) && attempts < 10
        
        return newPosition
    }
    
    // MARK: - isTooCloseToOtherDrones(position:)
    
    private func isTooCloseToOtherDrones(position: SCNVector3) -> Bool {
        for drone in droneNodes {
            let distance = distance(from: position, to: drone.position)
            if distance < minimumDroneSpacing {
                return true
            }
        }
        return false
    }
    
    // MARK: - distance(from:, to:)
    
    private func distance(from pos1: SCNVector3, to pos2: SCNVector3) -> Float {
        let dx = pos1.x - pos2.x
        let dy = pos1.y - pos2.y
        let dz = pos1.z - pos2.z
        return sqrt(dx * dx + dy * dy + dz * dz)
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
                    delegate?.arSceneManager(self, didUpdateDroneCount: droneNodes.count)
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
}

// MARK: - Delegates

extension ARSceneManager: ARSCNViewDelegate, ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        delegate?.arSceneManager(self, didUpdateTrackingState: frame.camera.trackingState)
    }
}
