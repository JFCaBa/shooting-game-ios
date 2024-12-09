//
//  DroneCountView.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import UIKit

final class DroneCountView: UIView {
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "drone"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .lightGray
        label.textAlignment = .right
        label.text = "0"
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
        addSubview(iconView)
        addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            // Icon
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            // Label
            countLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor),
            countLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor)
        ])
    }
    
    func updateCount(_ count: Int) {
        countLabel.text = "\(count)"
        if count > 0 {
            countLabel.textColor = .systemRed
            iconView.tintColor = .systemRed
        } else {
            countLabel.textColor = .lightGray
            iconView.tintColor = .lightGray
        }
    }
}
