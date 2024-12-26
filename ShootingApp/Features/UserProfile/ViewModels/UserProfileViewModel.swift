//
//  UserProfileViewModel.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Combine
import Foundation

final class UserProfileViewModel {
    @Published private(set) var error: Error?
    @Published private(set) var success: String?
    @Published private(set) var isLoading = false
    @Published private(set) var userData: Player.UserData?
    
    weak var coordinator: SettingsCoordinator?
    private let userService: UserServiceProtocol
    
    init(coordinator: SettingsCoordinator? = nil,
         userService: UserServiceProtocol = UserService()) {
        self.coordinator = coordinator
        self.userService = userService
    }
    
    func loadUserData() {
        guard let playerId = GameManager.shared.playerId else { return }
        
        isLoading = true
        Task {
            do {
                let data = try await userService.getUserDetails(playerId: playerId)
                await MainActor.run {
                    self.userData = data
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func passwordsMatch(_ password: String, _ confirm: String) -> Bool {
        if password.isEmpty && confirm.isEmpty {
            return true
        }
        return password == confirm && password.count >= 6
    }
    
    func updateProfile(nickname: String, password: String?, confirmPassword: String?) {
        guard let playerId = GameManager.shared.playerId,
        let userData
        else { return }
        
        isLoading = true
        Task {
            do {
                try await userService.updateUser(
                    playerId: playerId,
                    nickName: nickname,
                    email: userData.details?.email ?? "",
                    password: password ?? ""
                )
                self.success = "Profile updated successfully"
                self.isLoading = false
            } catch {
                self.error = error
                self.isLoading = false
            }
        }
    }
}
