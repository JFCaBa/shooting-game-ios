//
//  FeedbackView.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import UIKit

enum FeedbackStyle {
    case hit
    case kill
    case reward
    case custom(text: String, color: UIColor = .white, font: UIFont = .systemFont(ofSize: 32, weight: .bold))
    
    var color: UIColor {
        switch self {
        case .hit, .kill, .reward:
            return .systemRed
        case .custom(_, let color, _):
            return color
        }
    }
    
    var font: UIFont {
        switch self {
        case .hit, .kill, .reward:
            return .systemFont(ofSize: 48, weight: .heavy)
        case .custom(_, _, let font):
            return font
        }
    }
    
    func text(withAmount amount: Int? = nil) -> String {
        if let amount = amount {
            return "+\(amount) SHOT"
        }
        
        switch self {
        case .hit, .kill, .reward:
            return "SHOT"
        case .custom(let text, _, _):
            return text
        }
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
    
    func show(style: FeedbackStyle, amount: Int? = nil) {
        label.text = style.text(withAmount: amount)
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
