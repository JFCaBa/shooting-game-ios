//
//  OnboardingViewModel.swift
//  ShootingApp
//
//  Created by Jose on 23/11/2024.
//

import Foundation

final class OnboardingViewModel {
    weak var coordinator: OnboardingCoordinator?
    private let web3Service = Web3Service.shared
    
    @Published private(set) var showMetaMaskNotInstalledError = false
    
    func checkMetaMaskAndProceed() {
        showMetaMaskNotInstalledError = !web3Service.isMetaMaskInstalled()
    }
    
    func openAppStore() {
        web3Service.openAppStore()
    }
    
    func skip() {
        coordinator?.finishOnboarding()
    }
}
