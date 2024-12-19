//
//  RadarView.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import CoreLocation
import UIKit

final class RadarView: UIView {
    // MARK: - Properties
    private let numberOfCircles = 4
    private let scanLineLayer = CAShapeLayer()
    private let gridLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var targetLayers: [String: CAShapeLayer] = [:]
    private let locationManager = LocationManager.shared
    private var geoObjects: Array<GeoObject> = []
    
    // Size for target dots
    private let targetDotSize: CGFloat = 6
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        startScanAnimation()
        startTargetUpdates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Target Management
    func addTarget(_ geoObject: GeoObject) {
        geoObjects.append(geoObject)
        let targetLayer = CAShapeLayer()
        targetLayer.fillColor = getColorForType(geoObject.type).cgColor
        targetLayers[geoObject.id] = targetLayer
        layer.addSublayer(targetLayer)
        updateTargetPosition(geoObject)
    }
    
    func removeTarget(id: String) {
        geoObjects.removeAll { $0.id == id }
        targetLayers[id]?.removeFromSuperlayer()
        targetLayers.removeValue(forKey: id)
    }
    
    func removeAllTargets() {
        geoObjects.removeAll()
        targetLayers.values.forEach { $0.removeFromSuperlayer() }
        targetLayers.removeAll()
    }
    
    private func getColorForType(_ type: GeoObjectType) -> UIColor {
        switch type {
        case .drone:
            return .systemBlue
        case .target:
            return .systemRed
        case .powerup:
            return .systemYellow
        }
    }
    
    private func startTargetUpdates() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateAllTargetPositions()
        }
    }
    
    private func updateAllTargetPositions() {
        targetLayers.forEach { (id, layer) in
            if let object = geoObjects.first(where: { $0.id == id }) {
                updateTargetPosition(object)
            }
        }
    }
    
    private func updateTargetPosition(_ geoObject: GeoObject) {
        guard let userLocation = locationManager.location,
              let userHeading = locationManager.heading?.trueHeading,
              let layer = targetLayers[geoObject.id] else { return }
        
        let objectLocation = CLLocation(
            latitude: geoObject.coordinate.latitude,
            longitude: geoObject.coordinate.longitude
        )
        
        // Calculate relative angle and distance
        let bearing = userLocation.bearing(to: objectLocation)
        let relativeAngle = (bearing - userHeading + 360).truncatingRemainder(dividingBy: 360)
        let distance = userLocation.distance(from: objectLocation)
        
        // Convert to radar coordinates
        let radius = min(bounds.width, bounds.height) / 2
        let maxRange: CLLocationDistance = 500 // Maximum range in meters
        let normalizedDistance = min(distance / maxRange, 1.0)
        let distanceOnRadar = normalizedDistance * (radius - targetDotSize/2)
        
        let angleInRadians = relativeAngle * .pi / 180
        let x = bounds.midX + cos(angleInRadians) * distanceOnRadar
        let y = bounds.midY + sin(angleInRadians) * distanceOnRadar
        
        // Update dot position
        let dotPath = UIBezierPath(ovalIn: CGRect(x: x - targetDotSize/2,
                                                 y: y - targetDotSize/2,
                                                 width: targetDotSize,
                                                 height: targetDotSize))
        layer.path = dotPath.cgPath
    }
    
    // MARK: - Setup
    private func setupLayers() {
        // Background
        backgroundLayer.fillColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 0.9).cgColor
        layer.addSublayer(backgroundLayer)
        
        // Grid
        gridLayer.strokeColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3).cgColor
        gridLayer.fillColor = nil
        gridLayer.lineWidth = 1
        layer.addSublayer(gridLayer)
        
        // Scan line
        scanLineLayer.strokeColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8).cgColor
        scanLineLayer.lineWidth = 2
        layer.addSublayer(scanLineLayer)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(bounds.width, bounds.height) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Background circle
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        backgroundLayer.path = backgroundPath.cgPath
        
        // Grid circles and lines
        let gridPath = UIBezierPath()
        
        // Concentric circles
        for i in 1...numberOfCircles {
            let circleRadius = radius * CGFloat(i) / CGFloat(numberOfCircles)
            let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            gridPath.append(circlePath)
        }
        
        // Cross lines
        gridPath.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        gridPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        gridPath.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
        gridPath.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        
        gridLayer.path = gridPath.cgPath
    }
    
    // MARK: - Animation
    private func startScanAnimation() {
        // Create scan line path
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let path = UIBezierPath()
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
        scanLineLayer.path = path.cgPath
        
        // Create rotation animation
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * Double.pi
        animation.duration = 4.0
        animation.repeatCount = .infinity
        
        scanLineLayer.add(animation, forKey: "rotation")
    }
}
