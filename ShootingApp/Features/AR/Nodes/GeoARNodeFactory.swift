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
            configureDroneNode(node, location)
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
    
    private static func configureDroneNode(_ node: GeoARNode, _ location: SCNVector3) {
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
    
    private static func configureTargetNode(_ node: GeoARNode, _ location: SCNVector3) {
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
    
    private static func configurePowerupNode(_ node: GeoARNode, _ location: SCNVector3) {
        guard let scene = SCNScene(named: "sci_fi_crate.scn") else {
            // Fallback to basic geometry if the model fails to load
            let geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIColor.yellow
            node.geometry = geometry
            return
        }
        
        // Extract the root node from the loaded scene
        guard let modelNode = scene.rootNode.childNodes.first else { return }
        
        // Scale the model appropriately
//        modelNode.scale = SCNVector3(0.2, 0.2, 0.2)
        modelNode.position = SCNVector3(location.x, location.y, location.z)

        // **Set Pivot to Center**
//        let boundingBoxMin = modelNode.boundingBox.min
//        let boundingBoxMax = modelNode.boundingBox.max
//        let centerX = (boundingBoxMin.x + boundingBoxMax.x) / 2
//        let centerY = (boundingBoxMin.y + boundingBoxMax.y) / 2
//        let centerZ = (boundingBoxMin.z + boundingBoxMax.z) / 2
//        modelNode.pivot = SCNMatrix4MakeTranslation(centerX, centerY, centerZ)

        // Add the model as a child of the GeoARNode
        node.addChildNode(modelNode)
        
        // Floating animation
//        let floatUp = SCNAction.moveBy(x: CGFloat(location.x), y: 0.1, z: CGFloat(location.z), duration: 1.0)
//        let floatDown = SCNAction.moveBy(x: CGFloat(location.x), y: -0.1, z: CGFloat(location.z), duration: 1.0)
//        let floatSequence = SCNAction.sequence([floatUp, floatDown])
//        let floatingAnimation = SCNAction.repeatForever(floatSequence)
//        node.runAction(floatingAnimation)
        
        // Rotation animation
//        let rotation = CABasicAnimation(keyPath: "rotation")
//        rotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0)) // Rotate around the Y-axis
//        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
//        rotation.duration = 10.0
//        rotation.repeatCount = .infinity
//        modelNode.addAnimation(rotation, forKey: "rotateAroundCenter")
    }
}
