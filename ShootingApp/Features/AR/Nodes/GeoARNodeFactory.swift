//
//  GeoARNodeFactory.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import SceneKit
import CoreLocation

final class GeoARNodeFactory {
    static func createNode(for geoObject: GeoObject, location: SCNVector3) -> GeoARNode {
        let node = GeoARNode(
            id: geoObject.id,
            coordinate: geoObject.coordinate.toCLLocationCoordinate2D(),
            altitude: geoObject.coordinate.altitude
        )
        
        // Configure the node based on type
        switch geoObject.type {
        case .weapon:
            configureWeapon(node, location)
        case .target:
            configureTargetNode(node, location)
        case .powerup:
            configurePowerupNode(node, location)
        default:
            configurePowerupNode(node, location)
        }
        
        // Add metadata
        node.name = geoObject.id
        
        return node
    }
    
    private static func configureWeapon(_ node: GeoARNode, _ location: SCNVector3) {
        guard let scene = SCNScene(named: "weapon.scn") else {
            // Fallback to basic geometry if the model fails to load
            let geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIColor.yellow
            node.geometry = geometry
            
            // Add light to the node
            addLight(to: node)
            return
        }
        
        // Extract the root node from the loaded scene
        guard let modelNode = scene.rootNode.childNodes.first else { return }
        
        // Scale the model appropriately
//        modelNode.scale = SCNVector3(0.5, 0.5, 0.5)
        modelNode.position = location
        
        node.addChildNode(modelNode)
        
        // Add light to the node
        addLight(to: node)
        
        // Add pulsing animation
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.2, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ])
        node.runAction(SCNAction.repeatForever(pulseAction))
    }
    
    private static func configureTargetNode(_ node: GeoARNode, _ location: SCNVector3) {
        guard let scene = SCNScene(named: "santa_sleight.scn") else {
            // Fallback to basic geometry if the model fails to load
            let geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
            node.geometry = geometry
            
            // Add light to the node
            addLight(to: node)
            return
        }
                
        // Extract the root node from the loaded scene
        guard let modelNode = scene.rootNode.childNodes.first else { return }
        
        // Scale the model appropriately
        modelNode.scale = SCNVector3(0.01, 0.01, 0.01)
        modelNode.position = location

        // Add the model as a child of the GeoARNode
        node.addChildNode(modelNode)
        
        // Add light to the node
        addLight(to: node)
        
        // Add pulsing animation
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.2, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ])
        node.runAction(SCNAction.repeatForever(pulseAction))
    }
    
    private static func configurePowerupNode(_ node: GeoARNode, _ location: SCNVector3) {
        guard let scene = SCNScene(named: "weapons_crate.scn") else {
            // Fallback to basic geometry if the model fails to load
            let geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
            node.geometry = geometry
            
            // Add light to the node
            addLight(to: node)
            return
        }
                
        // Extract the root node from the loaded scene
        guard let modelNode = scene.rootNode.childNodes.first else { return }
        
        // Scale the model appropriately
        modelNode.scale = SCNVector3(0.03, 0.03, 0.03)
        modelNode.position = location

        // Add the model as a child of the GeoARNode
        node.addChildNode(modelNode)
        
        // Add light to the node
        addLight(to: node)
        
        // Add pulsing animation
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.2, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ])
        node.runAction(SCNAction.repeatForever(pulseAction))
    }
    
    // MARK: - Helpers
    /// Adds a light to the given node
    private static func addLight(to node: SCNNode) {
        let light = SCNLight()
        light.type = .directional
        light.color = UIColor.white
        light.intensity = 500
        light.attenuationStartDistance = 1.0
        light.attenuationEndDistance = 10.0
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0.5, 0.5, 0.5)
        
        node.addChildNode(lightNode)
    }
}
