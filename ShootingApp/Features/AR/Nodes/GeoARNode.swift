//
//  GeoARNode.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import ARKit
import CoreLocation

final class GeoARNode: SCNNode {
    // MARK: - Properties
    
    let coordinate: CLLocationCoordinate2D
    let altitude: CLLocationDistance
    private(set) var isPlaced = false
    private var isDestroyed = false
    var nodeId: String?
    
    // MARK: - Init
    
    init(id: String, coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance) {
        self.nodeId = id
        self.coordinate = coordinate
        self.altitude = altitude
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Position Updates
    
    func updatePosition(relativeTo userLocation: CLLocation, heading: CLHeading?) {
        let objectLocation = CLLocation(
            coordinate: coordinate,
            altitude: altitude,
            horizontalAccuracy: 1,
            verticalAccuracy: 1,
            timestamp: Date()
        )
        
        // Calculate distance and bearing
        let distance = userLocation.distance(from: objectLocation)
        let bearing = userLocation.bearing(to: objectLocation)
        
        // Convert real-world distance to scene scale (e.g., 1 meter = 1 unit)
        let sceneDistance = Float(distance)
        
        // Calculate heading-adjusted angle
        let userHeading = Float(heading?.trueHeading ?? 0) * .pi / 180
        let objectAngle = Float(bearing) * .pi / 180
        let angleFromUser = objectAngle - userHeading
        
        // Calculate x and z position using polar coordinates
        let xPosition = sceneDistance * sin(angleFromUser)
        let zPosition = -sceneDistance * cos(angleFromUser)
        
        // Set node position
        position = SCNVector3(xPosition, 0, zPosition)
    }
    
    func geoObjectWasHit() -> Bool {
        guard !isDestroyed else { return false }
        isDestroyed = true
        
        // Add Debris Effect
        addDebrisEffect()

        // Shrink and Fade Out the GeoObject
        let scaleDown = SCNAction.scale(to: 0.0, duration: 0.5)
        let fadeOut = SCNAction.fadeOut(duration: 0.5)
        let remove = SCNAction.removeFromParentNode()
        let cleanupSequence = SCNAction.sequence([SCNAction.group([scaleDown, fadeOut]), remove])
        runAction(cleanupSequence)
        
        return true
    }

    private func addDebrisEffect() {
        let debrisCount = 10 // Adjust the number of debris pieces
        for _ in 0..<debrisCount {
            // Create small debris pieces
            let debrisGeometry = SCNSphere(radius: 0.05) // Adjust size as needed
            debrisGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
            
            let debrisNode = SCNNode(geometry: debrisGeometry)
            debrisNode.position = self.position
            
            // Randomize debris movement
            let randomX = Float.random(in: -0.5...0.5)
            let randomY = Float.random(in: 0.5...1.5)
            let randomZ = Float.random(in: -0.5...0.5)
            let randomDirection = SCNVector3(randomX, randomY, randomZ)
            
            // Create an action for debris to move outward and fade out
            let moveAction = SCNAction.move(by: randomDirection, duration: 1.0)
            let fadeOutAction = SCNAction.fadeOut(duration: 1.0)
            let removeAction = SCNAction.removeFromParentNode()
            let debrisSequence = SCNAction.sequence([SCNAction.group([moveAction, fadeOutAction]), removeAction])
            
            debrisNode.runAction(debrisSequence)
            
            // Add debris to the parent node
            parent?.addChildNode(debrisNode)
        }
    }
}
