//
//  OnboardingPageViewController.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    weak var coordinator: OnboardingCoordinator?
    private var currentPage: OnboardingPage = .camera
    private var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        coordinator?.showPermissionsPage(.camera)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func setViewController(_ viewController: UIViewController, direction: UIPageViewController.NavigationDirection) {
        if let current = currentViewController {
            current.remove()
        }
        
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.didMove(toParent: self)
        currentViewController = viewController
    }
}

