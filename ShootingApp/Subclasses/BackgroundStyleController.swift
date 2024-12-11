//
//  BackgroundStyleController.swift
//  ShootingApp
//
//  Created by Jose on 11/12/2024.
//

import UIKit

class BackgroundStyleController: UIViewController {
    
    enum BackgroundStyle {
        case none
        case visualEffect
    }
    
    private var visualEffectView: UIVisualEffectView!
    
    var backgroundStyle: BackgroundStyle = .none {
        didSet { updateBackgroundStyle() }
    }
    
    private func updateBackgroundStyle() {
        switch backgroundStyle {
        case .none:
            visualEffectView?.removeFromSuperview()
            visualEffectView = nil
        case .visualEffect:
            visualEffectView = UIVisualEffectView()
            visualEffectView.effect = UIBlurEffect(style: .systemMaterial)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            
            view.insertSubview(visualEffectView, at: 0)
            
            NSLayoutConstraint.activate([
                visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
                visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}
