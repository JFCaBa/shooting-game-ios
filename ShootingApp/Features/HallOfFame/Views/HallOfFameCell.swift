//
//  HallOfFameCell.swift
//  ShootingApp
//
//  Created by Jose on 08/12/2024.
//

import UIKit

final class HallOfFameCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let identifier: String = "HallOfFameCell"
    
    // MARK: - UI Components
    
    private lazy var rankLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initialisers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    
    // MARK: - setupViews()
    
    private func setupViews() {
        contentView.backgroundColor = .secondarySystemFill
        contentView.addSubview(rankLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            // Rank
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            rankLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            // Name
            nameLabel.topAnchor.constraint(equalTo: rankLabel.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // Score
            scoreLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    public func configureWith(_ viewModel: HallOfFameCellViewModel) {
        contentView.backgroundColor = viewModel.backgroundColor
        rankLabel.text = viewModel.rank
        nameLabel.text = viewModel.name
        scoreLabel.text = viewModel.score
    }
}
