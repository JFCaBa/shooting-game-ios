//
//  BaseNodeManager.swift
//  ShootingApp
//
//  Created by Jose on 20/12/2024.
//

import ARKit
import Foundation
import SceneKit

class BaseNodeManager<T: SCNNode, D>: NodeManager {
    var nodes: [T] = []
    var data: [D] = []
    let sceneView: ARSCNView
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    func spawnNode(for data: D) {
        fatalError("Must be implemented by subclass")
    }
    
    func removeNode(_ node: T) {
        DispatchQueue.main.async {
            node.removeFromParentNode()
            node.geometry = nil
            self.nodes.removeAll { $0 == node }
        }
    }
    
    func removeAllNodes() {
        data.removeAll()
        nodes.forEach { node in
            DispatchQueue.main.async {
                node.removeFromParentNode()
                node.geometry = nil
            }
        }
        nodes.removeAll()
    }
    
    func handleHit(node: T) -> Bool {
        fatalError("Must be implemented by subclass")
    }
}
