//
//  NodeManager.swift
//  ShootingApp
//
//  Created by Jose on 20/12/2024.
//

import ARKit
import Foundation
import SceneKit

protocol NodeManager: AnyObject {
    associatedtype NodeType: SCNNode
    associatedtype DataType
    
    var nodes: [NodeType] { get set }
    var data: [DataType] { get set }
    var sceneView: ARSCNView { get }
    
    func spawnNode(for data: DataType)
    func removeNode(_ node: NodeType)
    func removeAllNodes()
    func handleHit(node: NodeType) -> Bool
}
