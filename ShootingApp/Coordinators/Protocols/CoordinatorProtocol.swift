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
    func showMap()
    func showSettings()
    func showWallet()
    func showAchievements()
}

extension CoordinatorProtocol {
    func addChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func showHome() {
        // Default empty implementation
    }
    
    func showMap() {
        // Default empty implementation
    }
    
    func showSettings() {
        // Default empty implementation
    }
    
    func showWallet() {
        // Default empty implementation
    }
    
    func showAchievements() {
        // Default empty implementation
    }
}
