//
//  TitleLabel.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import UIKit

extension OnboardingSheetViewController {
    class TitleLabel: UIView {
        // MARK: - Private Properties
        private var label: UILabel!
        
        // MARK: - Public Properties
        var text: String? {
            get {
                return label.text
            } set {
                label.text = newValue
            }
        }
        
        var attributtedText: NSAttributedString? {
            get {
                return label.attributedText
            } set {
                label.attributedText = newValue
            }
        }
        
        // MARK: - init(frame:)
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLabel()
        }
        

        // MARK: - init?(coder:)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private Methods
        private func setupLabel() {
            label = UILabel()
            label.font = .preferredFont(forTextStyle: .largeTitle, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 2
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            
            addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
            ])
        }
    }
}
