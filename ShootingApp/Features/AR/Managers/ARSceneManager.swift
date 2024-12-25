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
    private let droneManager: DroneNodeManager
    private let geoObjectManager: GeoObjectNodeManager
    private var currentZoom: Float = 1.0
    
    weak var delegate: ARSceneManagerDelegate?
    
    // MARK: - Initialization
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        self.droneManager = DroneNodeManager(sceneView: sceneView)
        self.geoObjectManager = GeoObjectNodeManager(sceneView: sceneView)
        super.init()
        setupScene()
        setupObservers()
        setupDelegates()
    }
    
    // MARK: - Setup
    
    private func setupScene() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene = SCNScene()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let configuration = ARWorldTrackingConfiguration()
            
//            if ARWorldTrackingConfiguration.supportsFrameSemantics(.bodyDetection) {
//                configuration.frameSemantics.insert(.bodyDetection)
//            }
            
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                configuration.frameSemantics.insert(.sceneDepth)
            }
            
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                configuration.frameSemantics.insert(.personSegmentationWithDepth)
            }
            
            DispatchQueue.main.async {
                self?.sceneView.session.run(configuration)
            }
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewDroneArrived(_:)),
            name: .newDroneArrived,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoveAllDrones),
            name: .removeAllDrones,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewGeoObjectArrived(_:)),
            name: .newGeoObjectArrived,
            object: nil)
    }
    
    // MARK: - Public Methods
    
    func getDrones() -> [DroneData] {
        return droneManager.data
    }
    
    func getGeoObjects() -> [GeoObject] {
        return geoObjectManager.data
    }
    
    func checkHit(at point: CGPoint) -> Bool {
        let hitResults = sceneView.hitTest(point, options: [
            SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
            SCNHitTestOption.ignoreChildNodes: false
        ])
        
        for result in hitResults {
            if let droneNode = findParentNode(ofType: ARDroneNode.self, for: result.node) {
                return droneManager.handleHit(node: droneNode)
            } else if let geoNode = result.node as? GeoARNode ?? findParentNode(ofType: GeoARNode.self, for: result.node) {
                return geoObjectManager.handleHit(node: geoNode)
            }
        }
        
        return false
    }
    
    func stop() {
        sceneView.session.pause()
    }
    
    func updateZoom(scale: CGFloat) {
        currentZoom = Float(scale)
        sceneView.transform = .init(a: CGFloat(scale), b: 0, c: 0,
                                  d: CGFloat(scale), tx: 0, ty: 0)
    }
    
    // MARK: - Helper Methods
    
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
}


private extension ARSceneManager {
    // MARK: - handleNewDroneArrived(_:)

    @objc func handleNewDroneArrived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let drone = userInfo["drone"] as? DroneData else { return }
        
        DispatchQueue.main.async {
            self.droneManager.spawnNode(for: drone)
        }
    }
    
    @objc func handleRemoveAllDrones() {
        droneManager.removeAllNodes()
        delegate?.arSceneManager(self, didUpdateDroneCount: 0)
    }
    
    // MARK: - handleNewGeoObjectArrived(_:)
    
    @objc func handleNewGeoObjectArrived(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let objects = userInfo["geoObject"] as? [GeoObject] else { return }
        
        DispatchQueue.main.async {
            // Process each object individually
            objects.forEach { object in
                self.geoObjectManager.spawnNode(for: object)
            }
        }
    }
}

// MARK: - NodeManagerDelegate
extension ARSceneManager: NodeManagerDelegate {
    func nodeManagerDidUpdateDroneCount(_ manager: any NodeManager, count: Int) { 
        DispatchQueue.main.async {  [weak self] in
            guard let self = self else { return }
            
            self.delegate?.arSceneManager(self, didUpdateDroneCount: count)
        }
    }
    
    func nodeManagerDidUpdateGeoObjectCount(_ manager: any NodeManager, count: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.arSceneManager(self, didUpdateGeoObjectCount: count)
        }
    }
    
    func nodeManager(_ manager: any NodeManager, droneHit drone: DroneData) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.arSceneManager(self, droneHit: drone)
        }
    }
    
    func nodeManager(_ manager: any NodeManager, geoObjectHit object: GeoObject) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.arSceneManager(self, geoObjectHit: object)
        }
    }
}

// MARK: - AR Delegates

extension ARSceneManager: ARSCNViewDelegate, ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        delegate?.arSceneManager(self, didUpdateTrackingState: frame.camera.trackingState)
    }
}

// MARK: - Adapter

extension ARSceneManager {
    private func setupDelegates() {
        droneManager.delegate = self
        geoObjectManager.delegate = self
    }
}
