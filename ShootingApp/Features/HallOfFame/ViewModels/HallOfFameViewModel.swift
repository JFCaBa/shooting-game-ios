//
//  HallOfFameViewModel.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

import Foundation
import Combine

final class HallOfFameViewModel {
    @Published private(set) var hallOfFame: HallOfFameResponse = []
    
    var hallOfFameService: HallOfFameService
    
    init(hallOfFameService: HallOfFameService = HallOfFameService()) {
        self.hallOfFameService = hallOfFameService
    }
    
    func fetchTopPlayers() {
        Task {
            do {
                let hallOfFame = try await hallOfFameService.getHallOfFame()
                await MainActor.run {
                    self.hallOfFame = hallOfFame
                }
            } catch {
                print("Error loading Hall Of Fame: \(error)")
            }
        }
    }
}
