//
//  AchievementsCoordinator.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import UIKit

final class AchievementsCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = AchievementsViewModel()
        let viewController = AchievementsViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showHallOfFame() {
        let viewModel = HallOfFameViewModel()
        let viewController = HallOfFameViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
