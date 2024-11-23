//
//  OnboardingCoordinator.swift
//  ShootingApp
//
//  Created by Jose on 22/11/2024.
//

import UIKit

final class OnboardingCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = OnboardingViewModel()
        viewModel.coordinator = self
        let viewController = OnboardingViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showHome() {
        parentCoordinator?.showHome()
    }
    
    func finishOnboarding() {
        print("ParentCoordinator: \(String(describing: parentCoordinator))")
        parentCoordinator?.showHome()
    }
}
