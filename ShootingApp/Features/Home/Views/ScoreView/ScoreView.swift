//
//  ScoreView.swift
//  ShootingApp
//
//  Created by Jose on 23/11/2024.
//

import UIKit

final class ScoreView: UIView {
    private lazy var hitsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "HITS"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGreen
        label.textAlignment = .right
        return label
    }()
    
    private lazy var hitsNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        return label
    }()
    
    private lazy var killsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "KILLS"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .right
        return label
    }()
    
    private lazy var killsNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemRed
        label.textAlignment = .right
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
        addSubview(hitsLabel)
        addSubview(hitsNumberLabel)
        addSubview(killsLabel)
        addSubview(killsNumberLabel)
        
        NSLayoutConstraint.activate([
            hitsLabel.topAnchor.constraint(equalTo: topAnchor),
            hitsLabel.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -16),
            
            hitsNumberLabel.topAnchor.constraint(equalTo: hitsLabel.bottomAnchor),
            hitsNumberLabel.trailingAnchor.constraint(equalTo: hitsLabel.trailingAnchor),
            
            killsLabel.topAnchor.constraint(equalTo: topAnchor),
            killsLabel.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 16),
            
            killsNumberLabel.topAnchor.constraint(equalTo: killsLabel.bottomAnchor),
            killsNumberLabel.leadingAnchor.constraint(equalTo: killsLabel.leadingAnchor)
        ])
    }
    
    func updateScore(hits: Int, kills: Int) {
        hitsNumberLabel.text = "\(hits)"
        killsNumberLabel.text = "\(kills)"
    }
}
