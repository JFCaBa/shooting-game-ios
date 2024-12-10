//
//  ARDroneModel.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import SceneKit

final class ARDroneNode: SCNNode {
    
    // MARK: - Properties
    
    private let droneBody: SCNNode
    private var rotors: [SCNNode]
    private var isDestroyed = false
    private var rotorAnimation: CAAnimation?
    var nodeId: String?
    
    // MARK: - init()
    
    override init() {
        droneBody = SCNNode()
        rotors = [SCNNode(), SCNNode(), SCNNode(), SCNNode()]
        super.init()
        //        setupDrone()
        //        startRotorAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupDrone()
    
    func setupDrone() {
        let bodyGeometry = SCNBox(width: 0.25, height: 0.05, length: 0.25, chamferRadius: 0.01)
        
        // Create grid pattern for top
        guard let topImage = UIImage.createGridPattern(
            size: CGSize(width: 64, height: 64),
            lineWidth: 1.0, spacing: 8.0,
            color: UIColor.black)
        else {
            return
        }
        let topPattern = UIImage.createCombinedPattern(baseColor: UIColor.white, overlayPattern: topImage)
        assert(topPattern != nil, "Pattern generation failed")
        
        let topMaterial = SCNMaterial()
        topMaterial.diffuse.contents = topPattern
        topMaterial.metalness.contents = 0.9
        topMaterial.roughness.contents = 0.1
        topMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(4, 4, 1)
        topMaterial.diffuse.wrapS = .repeat
        topMaterial.diffuse.wrapT = .repeat
        
        // Create grid pattern for bottom
        guard let bottomImage = UIImage.createHexagonPattern(
            size: CGSize(width: 32, height: 32),
            color: UIColor.black
        ) else {
            return
        }
        
        let bottomPattern = UIImage.createCombinedPattern(baseColor: UIColor.white, overlayPattern: bottomImage)
        
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = bottomPattern
        bottomMaterial.metalness.contents = 0.7
        bottomMaterial.roughness.contents = 0.3
        bottomMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(8, 8, 1)
        bottomMaterial.diffuse.wrapS = .repeat
        bottomMaterial.diffuse.wrapT = .repeat
        
        bodyGeometry.materials = [
            bottomMaterial,    // Front
            bottomMaterial,    // Right
            bottomMaterial,    // Back
            bottomMaterial,    // Left
            topMaterial,       // Top
            bottomMaterial     // Bottom
        ]
        
        droneBody.geometry = bodyGeometry
        addChildNode(droneBody)
        
        let bodyShape = SCNPhysicsShape(
            shapes: [
                SCNPhysicsShape(geometry: bodyGeometry, options: nil)
            ],
            transforms: nil
        )
        
        droneBody.physicsBody = SCNPhysicsBody(type: .dynamic, shape: bodyShape)
        droneBody.physicsBody?.mass = 0.5
        droneBody.physicsBody?.isAffectedByGravity = false
        
        addDetailPanels()
        setupArmsAndRotors()
        setupSensorsAndLights()
        startRotorAnimation()
        startDroneMove()
    }
    
    // MARK: - Detail Panels
    
    private func addDetailPanels() {
        // Create grid pattern for top
        guard let topImage = UIImage.createHexagonPattern(size: CGSize(width: 128, height: 128), color: UIColor.black)
        else {
            return print("Grid pattern generation failed")
        }
        
        let topPattern = UIImage.createCombinedPattern(baseColor: UIColor.lightGray, overlayPattern: topImage)
        assert(topPattern != nil, "Top Pattern generation failed")
        
        let panelMaterial = SCNMaterial()
        panelMaterial.diffuse.contents = topPattern
        panelMaterial.metalness.contents = 0.9
        panelMaterial.roughness.contents = 0.1
        
        let panelGeometry = SCNBox(width: 0.08, height: 0.01, length: 0.08, chamferRadius: 0.002)
        panelGeometry.materials = [panelMaterial]
        
        let panelPositions = [
            SCNVector3(0.06, 0.025, 0.06),
            SCNVector3(-0.06, 0.025, 0.06),
            SCNVector3(-0.06, 0.025, -0.06),
            SCNVector3(0.06, 0.025, -0.06)
        ]
        
        for position in panelPositions {
            let panel = SCNNode(geometry: panelGeometry)
            panel.position = position
            droneBody.addChildNode(panel)
        }
    }
    
    private func setupArmsAndRotors() {
        let armPositions = [
            SCNVector3(0.12, 0.03, 0.12),
            SCNVector3(-0.12, 0.03, 0.12),
            SCNVector3(-0.12, 0.03, -0.12),
            SCNVector3(0.12, 0.03, -0.12)
        ]
        
        for (index, position) in armPositions.enumerated() {
            let arm = createArm()
            arm.position = position
            droneBody.addChildNode(arm)
            
            let rotor = createRotor()
            rotor.position = SCNVector3(0, 0.035, 0)
            arm.addChildNode(rotor)
            rotors[index] = rotor
        }
    }
    
    private func setupSensorsAndLights() {
        // Front camera
        let sensorGeometry = SCNSphere(radius: 0.02)
        let sensorMaterial = SCNMaterial()
        sensorMaterial.diffuse.contents = UIColor.black
        sensorMaterial.metalness.contents = 0.9
        sensorMaterial.roughness.contents = 0.1
        sensorGeometry.materials = [sensorMaterial]
        
        let sensorNode = SCNNode(geometry: sensorGeometry)
        sensorNode.position = SCNVector3(0, -0.02, 0.08)
        droneBody.addChildNode(sensorNode)
        
        // Back LED
        let ledGeometry = SCNSphere(radius: 0.005)
        let ledMaterial = SCNMaterial()
        ledMaterial.diffuse.contents = UIColor.red
        ledMaterial.emission.contents = UIColor.red
        ledGeometry.materials = [ledMaterial]
        
        let ledNode = SCNNode(geometry: ledGeometry)
        ledNode.position = SCNVector3(0, -0.02, -0.08)
        droneBody.addChildNode(ledNode)
    }
    
    private func createArm() -> SCNNode {
        let arm = SCNNode()
        let armGeometry = SCNCylinder(radius: 0.01, height: 0.02)
        let armMaterial = SCNMaterial()
        armMaterial.diffuse.contents = UIColor.darkGray
        armMaterial.metalness.contents = 0.8
        armMaterial.roughness.contents = 0.2
        armGeometry.materials = [armMaterial]
        arm.geometry = armGeometry
        return arm
    }
    
    private func createRotor() -> SCNNode {
        let rotor = SCNNode()
        let rotorGeometry = SCNBox(width: 0.12, height: 0.002, length: 0.01, chamferRadius: 0)
        let rotorMaterial = SCNMaterial()
        rotorMaterial.diffuse.contents = UIColor.black
        rotorMaterial.metalness.contents = 0.7
        rotorMaterial.roughness.contents = 0.3
        rotorGeometry.materials = [rotorMaterial]
        rotor.geometry = rotorGeometry
        return rotor
    }
    
    private func startRotorAnimation() {
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 0.2
//        rotation.speed = 2.0
        rotation.repeatCount = .infinity
        
        rotors.enumerated().forEach { index, rotor in
//            if index % 2 == 0 {
//                rotation.speed = -2.0  // Reverse and double speed for alternating rotors
//            }
            rotor.addAnimation(rotation, forKey: "rotorSpin")
        }
    }
    
    private func startDroneMove() {
        // Hover animation
        let hover = CABasicAnimation(keyPath: "position.y")
        hover.fromValue = position.y
        hover.toValue = position.y + 0.05
        hover.duration = 1.0
        hover.autoreverses = true
        hover.repeatCount = .infinity
        hover.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Random sway
        let swayX = CABasicAnimation(keyPath: "position.x")
        swayX.fromValue = position.x - 0.1
        swayX.toValue = position.x + 0.1
        swayX.duration = Double.random(in: 2.0...3.0)
        swayX.autoreverses = true
        swayX.repeatCount = .infinity
        swayX.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let swayZ = CABasicAnimation(keyPath: "position.z")
        swayZ.fromValue = position.z - 0.1
        swayZ.toValue = position.z + 0.1
        swayZ.duration = Double.random(in: 2.0...3.0)
        swayZ.autoreverses = true
        swayZ.repeatCount = .infinity
        swayZ.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Circular motion using SCNAction
        let radius: Float = 1.0 // Adjust radius as needed
        let duration = 5.0
        let isClockwise = Bool.random() ? 1.0 : -1.0 // Randomize direction
        let circularMotion = SCNAction.repeatForever(
            SCNAction.customAction(duration: duration) { node, time in
                let angle = CGFloat(time / CGFloat(duration) * 2 * .pi) * CGFloat(isClockwise)
                let x = CGFloat(radius) * cos(angle)
                let z = CGFloat(radius) * sin(angle)
                node.position = SCNVector3(x, CGFloat(node.position.y), z)
            }
        )

        // Run actions
        addAnimation(hover, forKey: "hover")
        addAnimation(swayX, forKey: "swayX")
        addAnimation(swayZ, forKey: "swayZ")
        runAction(circularMotion, forKey: "circularMotion")
    }
    
    func setPosition(x: Float, y: Float, z: Float) {
        position = SCNVector3(x, y, z)
    }
    
    func hit() -> Bool {
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
