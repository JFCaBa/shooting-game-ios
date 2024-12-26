//
//  LoginViewModel.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Combine
import Foundation

final class LoginViewModel {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var loginSuccess: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthServiceProtocol
    private let coordinator: LoginCoordinatorProtocol

    // MARK: - Initialization
    init(authService: AuthServiceProtocol, coordinator: LoginCoordinatorProtocol) {
        self.authService = authService
        self.coordinator = coordinator
        setupBindings()
    }

    // MARK: - Public Methods
    func login(email: String, password: String) {
        isLoading = true
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.error = error
                }
            } receiveValue: { [weak self] success in
                guard let self = self else { return }
                self.loginSuccess = success
                if success {
                    self.coordinator.navigateToHome()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Combine email and password validation to enable login button
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                return !email.isEmpty && !password.isEmpty
            }
            .assign(to: \.isLoginEnabled, on: self)
            .store(in: &cancellables)
    }
}
