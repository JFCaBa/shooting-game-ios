//
//  GeoARNodeFactory.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//


import SceneKit
import CoreLocation

final class GeoARNodeFactory {
    static func createNode(for geoObject: GeoObject) -> GeoARNode {
        let node = GeoARNode(
            id: geoObject.id,
            coordinate: geoObject.coordinate.toCLLocationCoordinate2D(),
            altitude: geoObject.coordinate.altitude
        )
        
        // Configure the node based on type
        switch geoObject.type {
        case .drone:
            configureDroneNode(node)
        case .target:
            configureTargetNode(node)
        case .powerup:
            configurePowerupNode(node)
        }
        
        // Add metadata
        node.name = geoObject.id
        
        return node
    }
    
    private static func configureDroneNode(_ node: GeoARNode) {
        let geometry = SCNBox(width: 0.5, height: 0.2, length: 0.5, chamferRadius: 0.05)
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry = geometry
        
        // Add rotors
        let rotorGeometry = SCNBox(width: 0.1, height: 0.02, length: 0.1, chamferRadius: 0)
        let rotorMaterial = SCNMaterial()
        rotorMaterial.diffuse.contents = UIColor.darkGray
        rotorGeometry.materials = [rotorMaterial]
        
        // Position rotors at corners
        let rotorPositions = [
            SCNVector3(0.2, 0.1, 0.2),
            SCNVector3(-0.2, 0.1, 0.2),
            SCNVector3(0.2, 0.1, -0.2),
            SCNVector3(-0.2, 0.1, -0.2)
        ]
        
        rotorPositions.forEach { position in
            let rotorNode = SCNNode(geometry: rotorGeometry)
            rotorNode.position = position
            node.addChildNode(rotorNode)
            
            // Add rotation animation
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
            rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            rotation.duration = 1.0
            rotation.repeatCount = .infinity
            rotorNode.addAnimation(rotation, forKey: "rotate")
        }
    }
    
    private static func configureTargetNode(_ node: GeoARNode) {
        let geometry = SCNSphere(radius: 3)
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        node.geometry = geometry
        
        // Add pulsing animation
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.2, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ])
        node.runAction(SCNAction.repeatForever(pulseAction))
    }
    
    private static func configurePowerupNode(_ node: GeoARNode) {
        let geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.05)
        geometry.firstMaterial?.diffuse.contents = UIColor.yellow
        node.geometry = geometry
        
        // Add rotation animation
        let rotationAction = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 3.0)
        node.runAction(SCNAction.repeatForever(rotationAction))
    }
}
