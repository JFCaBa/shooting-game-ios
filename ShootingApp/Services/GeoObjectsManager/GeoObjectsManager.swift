//
//  GeoObjectsManager.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import Foundation
import CoreLocation

final class GeoObjectsManager {
    // MARK: - Properties
    
    private let geoObjectService: GeoObjectServiceProtocol
    private let locationManager = LocationManager.shared
    private let searchRadius: Double = 500 // meters
    private var updateTimer: Timer?
    private var lastFetchLocation: CLLocation?
    private let minimumFetchDistance: Double = 50 // meters
    
    // MARK: - Published properties for UI updates
    
    @Published private(set) var nearbyObjects: [GeoObject] = []
    @Published private(set) var error: Error?
    
    // MARK: - Init
    
    init(geoObjectService: GeoObjectServiceProtocol = GeoObjectService()) {
        self.geoObjectService = geoObjectService
        setupLocationObserver()
        startPeriodicUpdates()
    }
    
    // MARK: - Setup
    
    private func setupLocationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocationUpdate),
            name: .locationDidUpdate,
            object: nil
        )
    }
    
    private func startPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: 60, // Update every minute
            repeats: true
        ) { [weak self] _ in
            self?.fetchNearbyObjectsIfNeeded()
        }
    }
    
    // MARK: - Location Updates
    
    @objc private func handleLocationUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let location = userInfo["location"] as? CLLocation else { return }
        
        checkAndUpdateLocation(location)
    }
    
    private func checkAndUpdateLocation(_ newLocation: CLLocation) {
        guard let lastLocation = lastFetchLocation else {
            fetchNearbyObjects(at: newLocation)
            return
        }
        
        let distance = newLocation.distance(from: lastLocation)
        if distance >= minimumFetchDistance {
            fetchNearbyObjects(at: newLocation)
        }
    }
    
    // MARK: - Fetch Objects
    
    private func fetchNearbyObjectsIfNeeded() {
        guard let location = locationManager.location else { return }
        fetchNearbyObjects(at: location)
    }
    
    private func fetchNearbyObjects(at location: CLLocation) {
        Task {
            do {
                let objects = try await geoObjectService.getNearbyObjects(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    radius: searchRadius
                )
                
                await MainActor.run {
                    self.nearbyObjects = objects
                    self.lastFetchLocation = location
                }
                
                NotificationCenter.default.post(
                    name: .geoObjectsUpdated,
                    object: nil,
                    userInfo: ["objects": objects]
                )
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    func stopUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
