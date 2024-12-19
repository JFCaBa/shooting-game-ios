//
//  GroupIndicatorView.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import UIKit

final class GroupIndicatorView: GeoObjectIndicatorView {
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemRed
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    init(geoObject: GeoObject, count: Int, range: DistanceRange) {
        super.init(geoObject: geoObject)
        setupCountLabel()
        updateCount(count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCountLabel() {
        addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: -5),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5),
            countLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            countLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func updateCount(_ count: Int) {
        countLabel.text = "\(count)"
        
        // Update size based on number of digits
        let width = count < 10 ? 16 : 24
        countLabel.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
    }
}
