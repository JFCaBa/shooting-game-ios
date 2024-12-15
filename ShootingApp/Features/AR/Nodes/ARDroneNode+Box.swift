//
//  ARDroneNode+Box.swift
//  ShootingApp
//
//  Created by Jose on 14/12/2024.
//

import SceneKit

extension ARDroneNode {
    
    // MARK: - setupDrone()
    
    func setupBoxDrone(droneBody: SCNNode) {
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
        
        addDetailPanels(droneBody)
        setupArmsAndRotors(droneBody)
        setupSensorsAndLights(droneBody)
        startRotorAnimation()
    }
    
    private func setupSensorsAndLights(_ droneBody: SCNNode) {
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
    
    
    // MARK: - Detail Panels
    
    private func addDetailPanels(_ droneBody: SCNNode) {
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
    
    private func setupArmsAndRotors(_ droneBody: SCNNode) {
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
    
    // MARK: - Start Rotor Animation
    
    @MainActor
    private func startRotorAnimation() {
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.fromValue = NSValue(scnVector4: SCNVector4(0, 1, 0, 0))
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 0.2
        rotation.speed = 2.0
        rotation.repeatCount = .infinity
        
        rotors.enumerated().forEach { index, rotor in
            if index % 2 == 0 {
                rotation.speed = -2.0  // Reverse and double speed for alternating rotors
            }
            rotor.addAnimation(rotation, forKey: "rotorSpin")
        }
    }}
