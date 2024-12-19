//
//  GeoObjectIndicatorsManager.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import UIKit
import CoreLocation

final class GeoObjectIndicatorsManager: UIView {
    // MARK: - Properties
    
    private var indicators: [String: GeoObjectIndicatorView] = [:]
    private let padding: CGFloat = 50
    private var updateTimer: Timer?
    private let locationManager = LocationManager.shared
    private let groupManager = GeoObjectGroupManager()
    private var currentGroups: [GeoObjectGroup] = []
    private var currentObjects: [GeoObject] = []
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        startPositionUpdates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopPositionUpdates()
    }
    
    // MARK: - Indicator Management
    
    func addIndicator(for geoObject: GeoObject) {
        // Remove existing indicator if present
        indicators[geoObject.id]?.removeFromSuperview()
        
        // Create and add new indicator
        let indicator = GeoObjectIndicatorView(geoObject: geoObject)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        indicators[geoObject.id] = indicator
        
        // Start animations
        indicator.startAnimating()
        
        // Initial position update
        updateIndicatorPosition(indicator, for: geoObject)
        
        // Store object for grouping
        currentObjects.append(geoObject)
        updateGroups()
    }
    
    func removeIndicator(for geoObjectId: String) {
        indicators[geoObjectId]?.stopAnimating()
        indicators[geoObjectId]?.removeFromSuperview()
        indicators.removeValue(forKey: geoObjectId)
        
        // Update objects and groups
        currentObjects.removeAll { $0.id == geoObjectId }
        updateGroups()
    }
    
    func removeAllIndicators() {
        indicators.values.forEach { indicator in
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
        indicators.removeAll()
        currentObjects.removeAll()
        currentGroups.removeAll()
    }
    
    // MARK: - Group Management
    
    private func updateGroups() {
        guard let userLocation = locationManager.location else { return }
        
        // Get grouped objects
        let groups = groupManager.groupObjects(currentObjects, near: userLocation)
        currentGroups = groups
        
        // Update indicators based on groups
        updateGroupIndicators()
    }
    
    private func updateGroupIndicators() {
        currentGroups.forEach { group in
            let groupId = "\(group.type)-\(group.range)"
            
            if let indicator = indicators[groupId] as? GroupIndicatorView {
                // Update existing group indicator
                indicator.updateCount(group.count)
            } else {
                // Create new group indicator
                let groupObject = GeoObject(
                    id: groupId,
                    type: group.type,
                    coordinate: GeoCoordinate(
                        latitude: group.averagePosition.latitude,
                        longitude: group.averagePosition.longitude,
                        altitude: 0
                    ),
                    metadata: GeoObjectMetadata(
                        reward: nil,
                        expiresAt: nil,
                        spawnedAt: Date()
                    )
                )
                
                let indicator = GroupIndicatorView(
                    geoObject: groupObject,
                    count: group.count,
                    range: group.range
                )
                indicator.translatesAutoresizingMaskIntoConstraints = false
                addSubview(indicator)
                indicators[groupId] = indicator
                indicator.startAnimating()
            }
        }
    }
    
    // MARK: - Position Updates
    
    private func startPositionUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateAllPositions()
        }
    }
    
    private func stopPositionUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateAllPositions() {
        guard let userLocation = locationManager.location,
              let userHeading = locationManager.heading?.trueHeading else { return }
        
        indicators.forEach { (id, indicator) in
            if let groupId = id.split(separator: "-").first,
               let group = currentGroups.first(where: { "\($0.type)-\($0.range)" == id }) {
                // Update group indicator position
                updateIndicatorPosition(indicator, for: GeoObject(
                    id: id,
                    type: group.type,
                    coordinate: GeoCoordinate(
                        latitude: group.averagePosition.latitude,
                        longitude: group.averagePosition.longitude,
                        altitude: 0
                    ),
                    metadata: GeoObjectMetadata(reward: nil, expiresAt: nil, spawnedAt: Date())
                ))
            } else if let object = currentObjects.first(where: { $0.id == id }) {
                // Update individual indicator position
                updateIndicatorPosition(indicator, for: object)
            }
        }
    }
    
    private func updateIndicatorPosition(_ indicator: GeoObjectIndicatorView, for geoObject: GeoObject) {
        guard let userLocation = locationManager.location,
              let userHeading = locationManager.heading?.trueHeading else { return }
        
        let objectLocation = CLLocation(
            latitude: geoObject.coordinate.latitude,
            longitude: geoObject.coordinate.longitude
        )
        
        // Calculate relative angle
        let bearing = userLocation.bearing(to: objectLocation)
        let relativeAngle = (bearing - userHeading + 360).truncatingRemainder(dividingBy: 360)
        
        // Convert angle to screen position
        let screenPosition = calculateScreenPosition(for: relativeAngle)
        
        // Update constraints
        updateIndicatorConstraints(indicator, at: screenPosition)
    }
    
    private func calculateScreenPosition(for angle: Double) -> CGPoint {
        let radians = angle * .pi / 180
        let radius = min(bounds.width, bounds.height) / 2 - padding
        
        let x = cos(radians) * radius + bounds.width / 2
        let y = sin(radians) * radius + bounds.height / 2
        
        return CGPoint(x: x, y: y)
    }
    
    private func updateIndicatorConstraints(_ indicator: GeoObjectIndicatorView, at position: CGPoint) {
        // Remove existing constraints
        indicator.removeFromSuperview()
        addSubview(indicator)
        
        // Add new constraints
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: leadingAnchor, constant: position.x),
            indicator.centerYAnchor.constraint(equalTo: topAnchor, constant: position.y)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func getGeoObject(for id: String) -> GeoObject? {
        return currentObjects.first(where: { $0.id == id })
    }
}
