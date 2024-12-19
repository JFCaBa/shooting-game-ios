//
//  GeoObjectGroupManager.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import CoreLocation

// Define distance ranges for grouping
enum DistanceRange {
    case immediate   // 0-50m
    case close      // 50-200m
    case medium     // 200-500m
    case far        // 500m+
    
    static func from(distance: CLLocationDistance) -> DistanceRange {
        switch distance {
        case 0..<50:
            return .immediate
        case 50..<200:
            return .close
        case 200..<500:
            return .medium
        default:
            return .far
        }
    }
    
    var priority: Int {
        switch self {
        case .immediate: return 3
        case .close: return 2
        case .medium: return 1
        case .far: return 0
        }
    }
}

struct GeoObjectGroup {
    var objects: [GeoObject]
    let range: DistanceRange
    let type: GeoObjectType
    
    var count: Int { objects.count }
    
    // Calculate average position for the group
    var averagePosition: CLLocationCoordinate2D {
        let totalLat = objects.reduce(0) { $0 + $1.coordinate.latitude }
        let totalLon = objects.reduce(0) { $0 + $1.coordinate.longitude }
        return CLLocationCoordinate2D(
            latitude: totalLat / Double(objects.count),
            longitude: totalLon / Double(objects.count)
        )
    }
}

final class GeoObjectGroupManager {
    // MARK: - Properties
    
    private let maxVisibleGroups = 5
    private var currentUserLocation: CLLocation?
    
    // MARK: - Grouping Methods
    
    func groupObjects(_ objects: [GeoObject], near location: CLLocation) -> [GeoObjectGroup] {
        currentUserLocation = location
        
        // First, sort objects by distance and filter out any that are too far
        let sortedObjects = objects.sorted { first, second in
            let firstDistance = distance(to: first)
            let secondDistance = distance(to: second)
            return firstDistance < secondDistance
        }
        
        // Group by distance range and type
        var groups: [String: GeoObjectGroup] = [:]
        
        for object in sortedObjects {
            let distance = self.distance(to: object)
            let range = DistanceRange.from(distance: distance)
            let key = "\(range)-\(object.type.rawValue)"
            
            if var group = groups[key] {
                group.objects.append(object)
                groups[key] = group
            } else {
                groups[key] = GeoObjectGroup(
                    objects: [object],
                    range: range,
                    type: object.type
                )
            }
        }
        
        // Convert to array and sort by priority
        return Array(groups.values)
            .sorted { first, second in
                // First by distance range priority
                if first.range.priority != second.range.priority {
                    return first.range.priority > second.range.priority
                }
                // Then by number of objects
                return first.count > second.count
            }
            .prefix(maxVisibleGroups) // Limit number of visible groups
            .map { $0 }
    }
    
    // MARK: - Helper Methods
    
    private func distance(to object: GeoObject) -> CLLocationDistance {
        guard let userLocation = currentUserLocation else { return .infinity }
        
        let objectLocation = CLLocation(
            latitude: object.coordinate.latitude,
            longitude: object.coordinate.longitude
        )
        
        return userLocation.distance(from: objectLocation)
    }
}
