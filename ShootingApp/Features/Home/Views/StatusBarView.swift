//
//  StatusBarView.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import UIKit

final class StatusBarView: UIView {
    // MARK: - Properties
    
    private let icon: UIImage?
    private let maxValue: Float
    private var currentValue: Float
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView(image: icon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = tintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = tintColor
        progress.trackTintColor = .darkGray
        progress.progress = 1.0
        progress.transform = CGAffineTransform(scaleX: 1, y: 2)
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        return progress
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = tintColor
        label.text = "\(Int(currentValue))/\(Int(maxValue))"
        return label
    }()
    
    // MARK: - Initializers
    
    init(icon: UIImage?, tintColor: UIColor, maxValue: Float) {
        self.icon = icon
        self.maxValue = maxValue
        self.currentValue = maxValue
        super.init(frame: .zero)
        self.tintColor = tintColor
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(iconView)
        addSubview(progressView)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            progressView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Public Methods
    
    func updateValue(_ value: Float) {
        currentValue = value
        progressView.progress = value / maxValue
        label.text = "\(Int(value))/\(Int(maxValue))"
    }
}
