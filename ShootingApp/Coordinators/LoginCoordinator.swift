//
//  LoginCoordinator.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import UIKit

final class LoginCoordinator: LoginCoordinatorProtocol {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController? = UINavigationController()) {
        self.navigationController = navigationController
    }

    func startLoginFlow() {
        let viewModel = LoginViewModel(coordinator: self)
        let loginViewController = LoginViewController(viewModel: viewModel)
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func navigateToHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
