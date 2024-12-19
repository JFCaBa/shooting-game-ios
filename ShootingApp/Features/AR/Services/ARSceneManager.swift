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
    private var geoObjectNodes : [GeoARNode] = []
    private var drones: [DroneData] = []
    private var geoObjects: [GeoObject] = []
    private var timer: Timer?
    private let maxDrones = 3
    private let maxGeoObjects = 1
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
            
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.bodyDetection) {
                configuration.frameSemantics.insert(.personSegmentationWithDepth)
            }
            
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                configuration.frameSemantics.insert(.sceneDepth)
            }
            
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoveAllDrones),
            name: .removeAllDrones,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewGeoObjectArrived),
            name: .geoObjectsUpdated,
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
    
    @objc private func handleRemoveAllDrones() {
        drones.removeAll()
        
        // Remove nodes from scene and array
        droneNodes.forEach { node in
            DispatchQueue.main.async {
                node.removeFromParentNode()
                node.geometry = nil
            }
        }
        droneNodes.removeAll()
        
        DispatchQueue.main.async {
            self.delegate?.arSceneManager(self, didUpdateDroneCount: 0)
        }
    }
    
    // MARK: - spawnDroneIfNeeded()
    
    private func spawnDroneIfNeeded(drone: DroneData) {
        guard droneNodes.count < maxDrones else { return }
        print(drone)
        drones.append(drone)
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            self.droneNodes = self.droneNodes.filter { $0.parent != nil }
            
            let position = self.generateSpawnPosition(drone: drone)
            let node = ARDroneNode.init(with: drone.droneId, type: .fourRotorOne, position: position)
            
            DispatchQueue.main.async {
                self.sceneView.scene.rootNode.addChildNode(node)
                self.droneNodes.append(node)
                self.delegate?.arSceneManager(self, didUpdateDroneCount: self.droneNodes.count)
            }
        }
    }
    
    // MARK: - generateSpawnPosition()
    
    private func generateSpawnPosition(drone: DroneData) -> SCNVector3 {
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
            // If no camera transform is available, fallback to default spawn in front
            return SCNVector3(0, 1, -3)
        }
        
        // Player's current position in AR world
        let playerPosition = SCNVector3(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )

        // Calculate the spawn position
        let spawnPosition = SCNVector3(
            playerPosition.x + drone.position.x,
            playerPosition.y + drone.position.y,
            playerPosition.z + drone.position.z
        )
        
        return spawnPosition
    }
    
    // MARK: - numberOfDrones()
    
    func numberOfDrones() -> Int {
        return droneNodes.count
    }
    
    // MARK: - checkHit(at:)
    
    func checkHit(at point: CGPoint) -> Bool {
        let hitResults = sceneView.hitTest(point, options: [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.ignoreChildNodes: false
        ])
        
        for result in hitResults {
            if let droneNode = findParentNode(ofType: ARDroneNode.self, for: result.node) {
                let removed = droneNode.droneWasHit()
                if removed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        droneNode.removeFromParentNode()
                        droneNode.geometry = nil
                        self.droneNodes.removeAll { $0 == droneNode }
                        self.delegate?.arSceneManager(self, didUpdateDroneCount: self.droneNodes.count)
                        
                        if let drone = self.drones.first(where: {$0.droneId == droneNode.nodeId}) {
                            self.delegate?.arSceneManager(self, droneHitted: drone)
                            self.drones.removeAll { $0 == drone }
                            
                            SoundManager.shared.playSound(type: .explosion)
                        }
                    }
                    
                    return removed
                }
            } else if let geoNode = findParentNode(ofType: GeoARNode.self, for: result.node)  {
                let removed = geoNode.geoObjectWasHit()
                if removed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        geoNode.removeFromParentNode()
                        geoNode.geometry = nil
                        self.geoObjectNodes.removeAll { $0 == geoNode }
                        self.delegate?.arSceneManager(self, didUpdateDroneCount: self.droneNodes.count)
                        
                        if let geoObject = self.geoObjects.first(where: {$0.id == geoNode.nodeId}) {
                            self.delegate?.arSceneManager(self, geoObjectHit: geoObject)
                            self.geoObjects.removeAll { $0 == geoObject }
                            
                            SoundManager.shared.playSound(type: .explosion)
                        }
                    }
                    
                    return removed
                }
            }
        }
        
        return false
    }
    
    func findParentNode<T: SCNNode>(ofType type: T.Type, for node: SCNNode?) -> T? {
        var currentNode = node
        while let parent = currentNode?.parent {
            if let matchingNode = parent as? T {
                return matchingNode
            }
            currentNode = parent
        }
        return nil
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
        sceneView.transform = .init(a: CGFloat(scale),  b: 0,  c: 0,
                                     d: CGFloat(scale), tx: 0, ty: 0)
    }
}

extension ARSceneManager {
    @objc private func handleNewGeoObjectArrived(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let objects = userInfo["objects"] as? [GeoObject] else { return }
        
        DispatchQueue.main.async {
            // Remove existing nodes that are no longer in the updated objects list
            self.removeStaleGeoNodes(newObjects: objects)
            
            // Add/update nodes for new objects
            objects.forEach { object in
                if !self.geoObjectNodes.contains(where: { $0.name == object.id }) {
                    self.spawnGeoObjectIfNeeded(geoObject: object)
                }
            }
        }
    }
    
    private func removeStaleGeoNodes(newObjects: [GeoObject]) {
        let newObjectIds = Set(newObjects.map { $0.id })
        geoObjectNodes = geoObjectNodes.filter { node in
            if let nodeId = node.name, !newObjectIds.contains(nodeId) {
                node.removeFromParentNode()
                return false
            }
            return true
        }
    }
    
    private func spawnGeoObjectIfNeeded(geoObject: GeoObject) {
        guard geoObjectNodes.count < maxGeoObjects else { return }
        
        geoObjects.append(geoObject)
        let node = GeoARNodeFactory.createNode(for: geoObject)
        
        // Add to scene
        sceneView.scene.rootNode.addChildNode(node)
        geoObjectNodes.append(node)
        
        // Update node position
        if let location = LocationManager.shared.location {
            node.updatePosition(
                relativeTo: location,
                heading: LocationManager.shared.heading
            )
        }
        
        // Notify delegate
        delegate?.arSceneManager(self, didUpdateGeoObjectCount: geoObjectNodes.count)
    }
    
    func checkGeoObjectHit(at point: CGPoint) -> Bool {
        let hitResults = sceneView.hitTest(point, options: [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.ignoreChildNodes: false
        ])
        
        for result in hitResults {
            if let geoNode = findParentNode(ofType: GeoARNode.self, for: result.node) {
                if let objectId = geoNode.name,
                   let hitObject = geoObjects.first(where: { $0.id == objectId }) {
                    // Remove the node
                    geoNode.removeFromParentNode()
                    geoObjectNodes.removeAll { $0 == geoNode }
                    
                    // Notify delegate
                    delegate?.arSceneManager(self, geoObjectHit: hitObject)
                    return true
                }
            }
        }
        
        return false
    }
}

// MARK: - Delegates

extension ARSceneManager: ARSCNViewDelegate, ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        delegate?.arSceneManager(self, didUpdateTrackingState: frame.camera.trackingState)
    }
}
