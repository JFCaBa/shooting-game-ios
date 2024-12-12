//
//  AppCoordinator.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import UIKit

final class AppCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if !UserDefaults.standard.bool(forKey: UserDefaults.Keys.hasSeenOnboarding) {
            showOnboarding()
        } else {
            showHome()
        }
    }
    
    private func showOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.parentCoordinator = self
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func showHome() {
        let homeViewController = HomeViewController(coordinator: self)
        
        navigationController.setViewControllers([homeViewController], animated: true)
    }
    
    func showWallet() {
        let walletVC = WalletViewController()
        walletVC.modalPresentationStyle = .pageSheet
        
        if let sheet = walletVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(walletVC, animated: true)
    }
    
    func showMap() {
        let mapVC = MapViewController()
        mapVC.modalPresentationStyle = .fullScreen
        navigationController.present(mapVC, animated: true)
    }
    
    func showSettings() {
        let settingsCoordinator = SettingsCoordinator(navigationController: navigationController)
        settingsCoordinator.parentCoordinator = self
        addChildCoordinator(settingsCoordinator)
        settingsCoordinator.start()
    }
    
    func showAchievements() {
        let achievementCoordinator = AchievementsCoordinator(navigationController: navigationController)
        achievementCoordinator.parentCoordinator = self
        addChildCoordinator(achievementCoordinator)
        achievementCoordinator.start()
    }
}
