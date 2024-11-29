//
//  BaseOnboardingViewModel.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import Foundation
import Combine

protocol OnboardingViewModelProtocol {
    var permissionGranted: PassthroughSubject<Bool, Never> { get }
    func requestPermission()
    func skip()
}

class BaseOnboardingViewModel: OnboardingViewModelProtocol {
    weak var coordinator: OnboardingCoordinator?
    var permissionGranted = PassthroughSubject<Bool, Never>()
    
    init(coordinator: OnboardingCoordinator? = nil) {
        self.coordinator = coordinator
    }
    
    func requestPermission() {
        fatalError("Must be implemented by subclass")
    }
    
    func skip() {
        fatalError("Must be implemented by subclass")
    }
}
