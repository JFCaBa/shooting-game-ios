//
//  AchievementCell.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import UIKit

final class AchievementCell: UICollectionViewCell {
    static let reuseIdentifier = "AchievementCell"
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            progressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            progressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            progressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            progressLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with achievement: Achievement, earned: Bool) {
        let iconName: String
        switch achievement.type {
        case .kills: iconName = "target"
        case .hits: iconName = "scope"
        case .survivalTime: iconName = "clock"
        case .accuracy: iconName = "camera.metering.spot"
        }
        
        iconImageView.image = UIImage(systemName: iconName)
        titleLabel.text = "\(achievement.type.description) \(achievement.milestone)"
        
        if earned {
            iconImageView.tintColor = .systemGreen
            titleLabel.textColor = .label
            progressLabel.textColor = .systemGreen
            progressLabel.text = "Achievement Unlocked! 🏆"
            containerView.alpha = 1.0
        } else {
            iconImageView.tintColor = .systemGray
            titleLabel.textColor = .secondaryLabel
            progressLabel.textColor = .secondaryLabel
            progressLabel.text = "Progress: \(achievement.progress)/\(achievement.milestone)"
            containerView.alpha = 0.7
        }
    }
}
