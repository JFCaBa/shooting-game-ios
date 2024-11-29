//
//  OnboardingCoordinator.swift
//  ShootingApp
//
//  Created by Jose on 22/11/2024.
//

import UIKit

enum OnboardingPage {
    case camera
    case location
    case notifications
    case wallet
}

class OnboardingCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var parentCoordinator: CoordinatorProtocol?
    var childCoordinators: [CoordinatorProtocol] = []
    private var pageViewController: OnboardingPageViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let pageVC = OnboardingPageViewController()
        pageVC.coordinator = self
        pageVC.modalPresentationStyle = .fullScreen
        navigationController.setViewControllers([pageVC], animated: false)
        self.pageViewController = pageVC
    }
    
    func showPermissionsPage(_ page: OnboardingPage) {
        switch page {
        case .camera:
            let viewModel = CameraPermissionViewModel(coordinator: self)
            let vc = CameraPermissionViewController(viewModel: viewModel)
            pageViewController?.setViewController(vc, direction: .forward)
        case .location:
            let viewModel = LocationPermissionViewModel(coordinator: self)
            let vc = LocationPermissionViewController(viewModel: viewModel)
            pageViewController?.setViewController(vc, direction: .forward)
        case .notifications:
            let viewModel = NotificationsPermissionViewModel(coordinator: self)
            let vc = NotificationsPermissionViewController(viewModel: viewModel)
            pageViewController?.setViewController(vc, direction: .forward)
        case .wallet:
            let viewModel = WalletConnectionViewModel(coordinator: self)
            let vc = WalletConnectionViewController(viewModel: viewModel)
            pageViewController?.setViewController(vc, direction: .forward)
        }
    }
    
    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaults.Keys.hasSeenOnboarding)
        parentCoordinator?.showHome()
    }
}
