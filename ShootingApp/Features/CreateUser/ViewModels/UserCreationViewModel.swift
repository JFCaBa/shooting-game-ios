//
//  UserCreationViewModel.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Combine
import Foundation

class UserCreationViewModel {
    // MARK: - Coordinator delegate
    
    weak var coordinator: SettingsCoordinator?
    
    // MARK: - Publised
    
    @Published private(set) var error: Error?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var token: Player.Token?
    
    private let tokenService: UserServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - init
    
    init(tokenService: UserServiceProtocol = UserService()) {
        self.tokenService = tokenService
        readToken()
    }
    
    // MARK: - store(token:)
    
    private func store(token: String) {
        do {
            try KeychainManager.shared.saveToken(token)
        } catch {
            self.error = error
        }
    }
    
    // MARK: - readToken()
    
    private func readToken() {
        do {
            if let token = try KeychainManager.shared.readToken() {
                self.token = Player.Token(token: token)
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - API
    
    func passwordsMatch(_ password: String, _ confirm: String) -> Bool {
        let hasMinLength = password.count >= 8
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasNumber = password.contains(where: { $0.isNumber })
        
        return hasMinLength && hasUppercase && hasNumber && password == confirm
    }
    
    func createUser(nickname: String, email: String, password: String, confirmPassword: String) {
        guard password == confirmPassword,
              let playerId = GameManager.shared.playerId
        else {
            error = UserError.passwordMismatch
            return
        }
        
        Task {
            do {
                let token = try await tokenService.sendUserDetails(playerId: playerId, nickName: nickname, email: email, password: password)
                
                self.token = token
                self.store(token: token.token)
                            
            } catch {
                self.error = error
            }
        }
    }
}
