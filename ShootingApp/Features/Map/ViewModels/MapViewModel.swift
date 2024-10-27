//
//  MapViewModel.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation
import MapKit
import CoreLocation

final class MapViewModel {
    private let coreDataManager = CoreDataManager.shared
    private let queueManager = DispatchQueueManager.shared
    var playersUpdated: (([Player]) -> Void)?
    
    init() {
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlayersUpdate),
            name: NSNotification.Name("PlayersUpdated"),
            object: nil
        )
    }
    
    @objc private func handlePlayersUpdate() {
        refreshPlayers()
    }
    
    func refreshPlayers() {
        queueManager.performCoreDataOperation { [weak self] in
            let players = self?.coreDataManager.getStoredPlayers() ?? []
            self?.queueManager.performOnMainThread {
                self?.playersUpdated?(players)
            }
        }
    }
    
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
