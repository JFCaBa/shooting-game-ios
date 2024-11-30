//
//  HomeViewModel.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var reward: RewardResponse?
    @Published var error: Error?
    
    weak var coordinator: AppCoordinator?

    private let gameManager = GameManager.shared
    private let web3Service = Web3Service.shared
    private var locationManager: CLLocationManager?
    let rewardService: RewardServiceProtocol
    
    init(rewardService: RewardServiceProtocol = RewardService()) {
        self.rewardService = rewardService
        start()
    }
    
    func start() {
        setupLocation()
        gameManager.startGame()
    }
    
    func adReward() {
        guard let address = gameManager.playerId else { return }
        
        Task {
            do {
                reward = try await rewardService.adReward(for: address)
            } catch {
                self.error = error
            }
        }
    }
    
    func shoot(isValid: Bool = true) {
        guard let location = locationManager?.location else { return }
        
        let locationData = LocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude,
            accuracy: location.horizontalAccuracy
        )
        
        gameManager.shoot(
            location: locationData,
            heading: locationManager?.heading?.trueHeading ?? 0
        )
    }
    
    private func setupLocation() {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
        locationManager?.startUpdatingHeading()
    }
    
    deinit {
        gameManager.endGame()
    }
}
