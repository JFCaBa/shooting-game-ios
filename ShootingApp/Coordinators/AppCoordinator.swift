//
//  AppCoordinator.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import UIKit

final class AppCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []
    
    // MARK: - init(navigationController:)
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - start()
    
    func start() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.parentCoordinator = self
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    // MARK: - showHome()
    
    func showHome() {
        let homeViewModel = HomeViewModel()
        homeViewModel.coordinator = self
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        navigationController.setViewControllers([homeViewController], animated: true)
        print("Navigated to Home from AppCoordinator")
    }
    
    // MARK: - showWallet()
    
    func showWallet() {
        let walletVC = WalletViewController()
        walletVC.modalPresentationStyle = .pageSheet
        
        if let sheet = walletVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(walletVC, animated: true)
    }
    
    // MARK: - showAchievements()
    
    func showAchievements() {
        let viewModel = AchievementsViewModel()
        let achievementsVC = AchievementsViewController(viewModel: viewModel)
        achievementsVC.modalPresentationStyle = .pageSheet
        
        if let sheet = achievementsVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(achievementsVC, animated: true)
    }
}
