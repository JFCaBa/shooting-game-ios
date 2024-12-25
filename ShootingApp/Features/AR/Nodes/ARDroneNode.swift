//
//  ARDroneModel.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import SceneKit

final class ARDroneNode: SCNNode {
    
    // MARK: - Properties
    
    private var droneBody =  SCNNode()
    private var isDestroyed = false
    private var rotorAnimation: CAAnimation?
    private var type: DroneType
    var rotors = [SCNNode(), SCNNode(), SCNNode(), SCNNode()]
    var nodeId: String?
    
    // MARK: - init()
    
    init(with id: String, type: DroneType, position: SCNVector3) {
        self.nodeId = id
        self.type = type
        super.init()
        self.position = position
        setupDrone(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupDrone(_ type:)
    
    func setupDrone(_ type: DroneType){
        switch type {
        case .box:
            setupBoxDrone(droneBody: droneBody)
            
        default:
            loadDroneModel(type: type)
            startBouncing()
        }
        
        startDroneMove()
    }
    
    // MARK: - loadDroneModel(modelName:)
    
    func loadDroneModel(type: DroneType) {
        guard let modelURL = Bundle.main.url(forResource: type.rawValue, withExtension: "scn"),
              let node = SCNReferenceNode(url: modelURL) else {
            print("❌ Failed to load model")
            return
        }
        
        node.load()
        node.scale = type.scale
                
        addChildNode(node)
        
        startRotorAnimation(node: node)
    }
    
    // MARK: - Start Rotor Animation
    
    func startRotorAnimation(node: SCNNode) {
        // Locate rotors by name
        let rotorNames = ["Rotor_F_R", "Rotor_F_L", "Rotor_R_R", "Rotor_R_L"]
        for rotorName in rotorNames {
            if let rotor = node.childNode(withName: rotorName, recursively: true) {
                // Create rotation action
                let rotateAction = type.rotateAction
                rotor.runAction(rotateAction)
            }
        }
    }
    
    func startBouncing() {
        // Hover Animation
        let hover = SCNAction.repeatForever(
            SCNAction.sequence([
                SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 1.0),
                SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 1.0)
            ])
        )
        
        // Sway Animation
        let swayX = SCNAction.repeatForever(
            SCNAction.sequence([
                SCNAction.moveBy(x: 0.1, y: 0, z: 0, duration: Double.random(in: 2.0...3.0)),
                SCNAction.moveBy(x: -0.1, y: 0, z: 0, duration: Double.random(in: 2.0...3.0))
            ])
        )
        
        let swayZ = SCNAction.repeatForever(
            SCNAction.sequence([
                SCNAction.moveBy(x: 0, y: 0, z: 0.1, duration: Double.random(in: 2.0...3.0)),
                SCNAction.moveBy(x: 0, y: 0, z: -0.1, duration: Double.random(in: 2.0...3.0))
            ])
        )
        
        // Run Actions in Parallel
        let combinedAction = SCNAction.group([hover, swayX, swayZ])
        runAction(combinedAction, forKey: "droneBouncing")
    }
    
    func startDroneMove() {
        // Circular Motion Animation
        let radius: CGFloat = 4
        let duration = 8.0
        let isClockwise = Bool.random() ? 1.0 : -1.0 // Randomize direction
        
        let circularMotion = SCNAction.repeatForever(
            SCNAction.customAction(duration: duration) { node, elapsedTime in
                // Circular path calculation
                let angle = CGFloat(elapsedTime / CGFloat(duration) * 2 * .pi) * CGFloat(isClockwise)
                let x = radius * cos(angle)
                let z = radius * sin(angle)
                node.position = SCNVector3(Float(x), node.position.y, Float(z))
            }
        )
        
        // Run Actions in Parallel
        let combinedAction = SCNAction.group([circularMotion])
        runAction(combinedAction, forKey: "droneMovement")
    }
    
    func setPosition(x: Float, y: Float, z: Float) {
        position = SCNVector3(x, y, z)
    }
    
    func droneWasHit() -> Bool {
        guard !isDestroyed else { return false }
        isDestroyed = true
        
        rotors.forEach { $0.removeAllAnimations() }
        removeAnimation(forKey: "hover")
        
        let particleSystem = SCNParticleSystem()
        particleSystem.particleSize = 0.02
        particleSystem.particleColor = .orange
        particleSystem.particleLifeSpan = 1.0
        particleSystem.emitterShape = droneBody.geometry
        particleSystem.birthRate = 500
        particleSystem.spreadingAngle = 180
        particleSystem.particleVelocity = 0.5
        
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem)
        addChildNode(particleNode)
        
        let currentY = position.y
        
        let fallAndSpin = SCNAction.group([
            SCNAction.moveBy(x: 0, y: CGFloat(-currentY) - 1, z: 0, duration: 1.5),
            SCNAction.rotateBy(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -2...2), z: CGFloat.random(in: -2...2), duration: 1.5)
        ])
        
        runAction(fallAndSpin) { [weak self] in
            self?.removeFromParentNode()
        }
        
        return true
    }
}

// MARK: - Helpers

extension ARDroneNode {
    // Debug helper
    private func debugPrintNodeHierarchy(_ node: SCNNode, level: Int = 0) {
        let indent = String(repeating: "  ", count: level)
        print("\(indent)Node: \(node.name ?? "unnamed")")
        print("\(indent)Geometry: \(node.geometry != nil ? "yes" : "no")")
        
        for childNode in node.childNodes {
            debugPrintNodeHierarchy(childNode, level: level + 1)
        }
    }
}
