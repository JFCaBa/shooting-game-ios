//
//  AchievementCell.swift
//  ShootingApp
//
//  Created by Jose on 25/11/2024.
//

import UIKit

final class AchievementCell: UICollectionViewCell {
    // MARK: - Constants
    
    static let reuseIdentifier = "AchievementCell"
    
    // MARK: - UI Components
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - init(frame:)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // MARK: - init?(coder:)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            progressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - configure(with:,earned:)
    
    func configure(with achievement: Achievement, earned: Bool) {
        let iconName: String
        switch achievement.type {
        case .kills: iconName = "target"
        case .hits: iconName = "scope"
        case .survivalTime: iconName = "timer"
        case .accuracy: iconName = "bullseye"
        }
        
        iconView.image = UIImage(systemName: iconName)
        titleLabel.text = achievement.type.description
        progressLabel.text = "\(achievement.milestone)"
        
        if earned {
            iconView.tintColor = .systemBlue
            titleLabel.textColor = .systemBlue
            contentView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            progressLabel.textColor = .systemBlue
        } else {
            iconView.tintColor = .gray
            titleLabel.textColor = .label
            contentView.backgroundColor = .secondarySystemBackground
            progressLabel.textColor = .secondaryLabel
        }
    }
}
