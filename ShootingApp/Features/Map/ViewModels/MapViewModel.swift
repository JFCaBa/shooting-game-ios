//
//  MapViewModel.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import CoreLocation
import Foundation
import MapKit

final class MapViewModel {
    // MARK: Constants
    
    private let coreDataManager = CoreDataManager.shared
    private let queueManager = DispatchQueueManager.shared
    
    // MARK: - Properties
    
    var playersUpdated: (([Player]) -> Void)?
    
    // MARK: - Initialisers
    
    init() {
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - setupObservers()
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlayersUpdate),
            name: NSNotification.Name("PlayersUpdated"),
            object: nil
        )
    }
    
    // MARK: - handlePlayersUpdate()
    
    @objc private func handlePlayersUpdate() {
        refreshPlayers()
    }
    
    // MARK: - refreshPlayers()
    
    func refreshPlayers() {
        queueManager.performCoreDataOperation { [weak self] in
            let players = self?.coreDataManager.getStoredPlayers() ?? []
            self?.queueManager.performOnMainThread {
                self?.playersUpdated?(players)
            }
        }
    }
    
    // MARK: - createAnnotations(from:)
    
    func createAnnotations(from players: [Player]) -> [MKPointAnnotation] {
        return players.map { player -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: player.location.latitude,
                longitude: player.location.longitude
            )
            annotation.title = player.id
            return annotation
        }
    }
}
