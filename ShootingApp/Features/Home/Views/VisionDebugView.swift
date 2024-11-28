//
//  DebugView.swift
//  ShootingApp
//
//  Created by Jose on 28/11/2024.
//

import UIKit

final class DebugView: UIView {
    private let borderWidth: CGFloat = 2.0
    private let displayDuration: TimeInterval = 2.0
    private var hideTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor.red.cgColor
        isHidden = true
    }
    
    func showFor(seconds: TimeInterval = 2.0) {
        hideTimer?.invalidate()
        isHidden = false
        hideTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            self?.isHidden = true
        }
    }
}
