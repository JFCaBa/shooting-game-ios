//
//  DetailView.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//


import UIKit

extension OnboardingSheetViewController {
    class DetailView: UIView {
        // MARK: - Private Properties
        private var stackView: UIStackView!
        private var textStackView: UIStackView!
        private var titleLabel: UILabel!
        private var subtitleLabel: UILabel!
        private var imageView: UIImageView!
        
        // MARK: - Public Properties
        var image: String {
            didSet { imageView.image = UIImage(systemName: image) }
        }
        
        var title: String {
            didSet { titleLabel.text = title }
        }
        
        var subtitle: String {
            didSet { subtitleLabel.text = subtitle }
        }
        
        var _tintColor: UIColor {
            didSet { imageView.tintColor = _tintColor}
        }
        
        // MARK: - init(frame:)
        override init(frame: CGRect) {
            image = "figure.walk"
            title = "Text placeholder"
            subtitle = "Text placeholder"
            _tintColor = .systemBlue
            super.init(frame: frame)
            
            setupStackView()
            setupImageView()
            setupTextStackView()
            setupTitleLabel()
            setupSubtitleLabel()
        }
        
        // MARK: - init(coder:)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private Methods
        private func setupStackView() {
            stackView = UIStackView()
            stackView.spacing = 20
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        private func setupImageView() {
            imageView = UIImageView()
            imageView.tintColor = .systemBlue
            imageView.contentMode = .scaleAspectFit
            let configuration = UIImage.SymbolConfiguration(font: .scaledSystemFont(for: .body, pointSize: 48))
            imageView.image = UIImage(systemName: image, withConfiguration: configuration)
            
            stackView.addArrangedSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        private func setupTextStackView() {
            textStackView = UIStackView()
            textStackView.spacing = 3
            textStackView.axis = .vertical
            textStackView.alignment = .leading
            textStackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(textStackView)
        }
        
        private func setupTitleLabel() {
            titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .label
            titleLabel.font = .preferredFont(forTextStyle: .callout, weight: .bold)
            titleLabel.numberOfLines = 0
            
            textStackView.addArrangedSubview(titleLabel)
        }
        
        private func setupSubtitleLabel() {
            subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.font = .preferredFont(forTextStyle: .callout)
            subtitleLabel.numberOfLines = 0
            
            textStackView.addArrangedSubview(subtitleLabel)
        }
    }
}

