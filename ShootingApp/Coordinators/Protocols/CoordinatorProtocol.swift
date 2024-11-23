//
//  CoordinatorProtocol.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    var parentCoordinator: CoordinatorProtocol? { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }
    
    func start()
    func showHome()
    func showWallet()
}

extension CoordinatorProtocol {
    func addChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func showHome() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func showWallet() {
        // Default empty implementation
    }
}
