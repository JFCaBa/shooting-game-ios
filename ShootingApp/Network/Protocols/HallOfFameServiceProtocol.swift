//
//  HallOfFameServiceProtocol.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

protocol HallOfFameServiceProtocol {
    func getHallOfFame() async throws -> HallOfFameResponse
}
