//
//  WalletConnectionViewModel.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import Combine
import Foundation

final class WalletConnectionViewModel: BaseOnboardingViewModel {
    private let web3Service: Web3Service
    private var notificationCancellable: AnyCancellable?
    
    init(coordinator: OnboardingCoordinator? = nil, web3Service: Web3Service = .shared) {
        self.web3Service = web3Service
        super.init(coordinator: coordinator)
        setupNotifications()
    }
    
    private func setupNotifications() {
        notificationCancellable = NotificationCenter.default.publisher(for: .walletConnectionChanged)
            .sink { [weak self] _ in
                if self?.web3Service.isConnected == true {
                    self?.permissionGranted.send(true)
                    self?.coordinator?.finishOnboarding()
                }
            }
    }
    
    override func requestPermission() {
        Task {
            do {
                _ = try await web3Service.connect()
                // Connection success will be handled by notification
            } catch {
                permissionGranted.send(false)
            }
        }
    }
    
    override func skip() {
        coordinator?.finishOnboarding()
    }
}
