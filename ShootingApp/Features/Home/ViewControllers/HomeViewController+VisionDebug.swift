//
//  HomeViewController+Debug.swift
//  ShootingApp
//
//  Created by Jose on 28/11/2024.
//

import UIKit
import AVFoundation

extension HomeViewController: AntiCheatDebugDelegate {
    func setupDebugViews() {
        visionDebugView = VisionDebugView(frame: .zero)
        view.addSubview(visionDebugView)
        AntiCheatSystem.shared.debugDelegate = self
    }
    
    func showDebugRect(_ visionRect: CGRect) {
        DispatchQueue.main.async {
            let viewRect = self.convertFromVisionToView(visionRect)
            self.visionDebugView.showAt(rect: viewRect)
        }
    }
    
    private func convertFromVisionToView(_ visionRect: CGRect) -> CGRect {
        let viewBounds = view.bounds
        
        // Vision coordinates are normalized (0-1) and inverted vertically
        let x = visionRect.minX * viewBounds.width
        let y = (1 - visionRect.maxY) * viewBounds.height
        let width = visionRect.width * viewBounds.width
        let height = visionRect.height * viewBounds.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
