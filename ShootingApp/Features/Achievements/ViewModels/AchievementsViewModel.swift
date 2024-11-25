//
//  AchievementsViewModel.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import Foundation
import Combine

final class AchievementsViewModel {
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var displayAchievements: [Achievement] = []
    
    private let web3Service: Web3ServiceProtocol
    private let achievementService: AchievementServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - init(web3Service:, achievementService:)
    
    init(web3Service: Web3ServiceProtocol = Web3Service.shared,
         achievementService: AchievementServiceProtocol = AchievementService.shared) {
        self.web3Service = web3Service
        self.achievementService = achievementService
        setupObservers()
        loadAchievements()
    }
    
    // MARK: - setPlaceholders(_:)
    
    func setPlaceholders(_ placeholders: [Achievement]) {
        self.displayAchievements = placeholders
    }
    
    // MARK: - setupObservers()
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .achievementUnlocked)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadAchievements()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - loadAchievements()
    
    func loadAchievements() {
        guard let wallet = web3Service.account else { return }
        
        Task {
            do {
                let achievements = try await achievementService.getAchievements(for: wallet)
                await MainActor.run {
                    self.achievements = achievements
                }
            } catch {
                print("Error loading achievements: \(error)")
            }
        }
    }
}
