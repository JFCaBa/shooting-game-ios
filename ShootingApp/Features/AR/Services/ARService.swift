//
//  ARService.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import Foundation

protocol ARServiceProtocol {
    func checkHit(at point: CGPoint) -> Bool
    func registerARView(_ view: ARContainerView)
}

final class ARService: ARServiceProtocol {
    static let shared = ARService()
    private var arView: ARContainerView?
    
    private init() {}
    
    func registerARView(_ view: ARContainerView) {
        self.arView = view
    }
    
    func checkHit(at point: CGPoint) -> Bool {
        guard let arView = arView else {
            print("Warning: ARView not registered")
            return false
        }
        return arView.checkHit(at: point)
    }
    
    func cleanup() {
        arView = nil
    }
}
