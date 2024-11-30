//
//  FeedbackView.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import UIKit

struct FeedbackStyle {
    let text: String
    let color: UIColor
    let font: UIFont
    
    static let hit = FeedbackStyle(
        text: "+1 SHOT",
        color: .systemRed,
        font: .systemFont(ofSize: 48, weight: .heavy)
    )
    
    static let kill = FeedbackStyle(
        text: "+5 SHOT",
        color: .systemRed,
        font: .systemFont(ofSize: 48, weight: .heavy)
    )
    
    static let reward = FeedbackStyle(
        text: "+10 SHOT",
        color: .systemRed,
        font: .systemFont(ofSize: 48, weight: .heavy)
    )
    
    static func custom(
        text: String,
        color: UIColor = .white,
        font: UIFont = .systemFont(ofSize: 32, weight: .bold)
    ) -> FeedbackStyle {
        FeedbackStyle(text: text, color: color, font: font)
    }
}

final class FeedbackView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func show(style: FeedbackStyle) {
        label.text = style.text
        label.textColor = style.color
        label.font = style.font
        
        showAnimation()
    }
    
    private func showAnimation() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
            self.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                self.alpha = 0.5
                self.transform = CGAffineTransform(translationX: 0, y: -75)
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }
}
