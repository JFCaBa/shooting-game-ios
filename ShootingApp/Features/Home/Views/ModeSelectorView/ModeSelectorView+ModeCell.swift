//
//  ModeSelectorView+ModeCell.swift
//  ShootingApp
//
//  Created by Jose on 29/12/2024.
//

import UIKit

extension ModeSelectorView {
    final class ModeCell: UICollectionViewCell {
        private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.textAlignment = .center
            return label
        }()
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                }
                label.textColor = isSelected ? .yellow : .label
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
        func configure(with text: String) {
            label.text = text
        }
        
        func setSelected(_ selected: Bool) {
            isSelected = selected
        }
        
        // This helps calculate the cell size based on content
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            attributes.frame = CGRect(x: attributes.frame.origin.x, y: attributes.frame.origin.y, width: size.width, height: attributes.frame.height)
            return attributes
        }
    }

}
