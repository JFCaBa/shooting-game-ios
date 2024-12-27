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
    @Published var loginSuccess: Bool?
    @Published var temporaryPassword: String?
    
    // MARK: - Public properties
    
    let coordinator: LoginCoordinatorProtocol

    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService: LoginServiceProtocol

    // MARK: - Initialization
    
    init(networkService: LoginServiceProtocol = LoginService(), coordinator: LoginCoordinatorProtocol) {
        self.networkService = networkService
        self.coordinator = coordinator
        setupBindings()
    }
    
    // MARK: - store(token:)

    private func store(token: String) {
        do {
            try KeychainManager.shared.saveToken(token)
        } catch {
            self.error = error
        }
    }

    // MARK: - Public Methods
    
    func login(email: String, password: String) {
        isLoading = true
        Task {
            do {
                let token = try await networkService.sendLogin(email: email, password: password)
                self.store(token: token.token)
                self.loginSuccess = true
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func forgotPassword(email: String, playerId: String) {
        isLoading = true
        Task {
            do {
                let response = try await networkService.forgotPassword(email: email, playerId: playerId)
                self.store(token: response.token)
                self.temporaryPassword = response.temporaryPassword
            } catch {
                self.error = error
            }
            isLoading = false
        }
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
