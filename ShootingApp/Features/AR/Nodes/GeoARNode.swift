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
        guard !isPlaced else { return }
        
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
        isPlaced = true
    }
    
    func geoObjectWasHit() -> Bool {
        guard !isDestroyed else { return false }
        isDestroyed = true
        
        let particleSystem = SCNParticleSystem()
        particleSystem.particleColor = .red
        particleSystem.particleSize = 0.05
        particleSystem.particleLifeSpan = 2
        particleSystem.emitterShape = SCNSphere(radius: 0.1)
        particleSystem.birthRate = 500
        particleSystem.spreadingAngle = 360
        
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem)
        addChildNode(particleNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            particleNode.removeFromParentNode()
        }
        
        return true
    }
}
