//
//  OnboardingSheetViewController.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//
// EXAMPLE OF USE:
//
// ADD A SIMILAR METHOD TO ONE IN THE EXAMPLE
//
// ``` swift
// private func showOnboardingSheetIfNeeded() {
//   // Check if was already presented
//   if UserDefaults.standard.bool(forKey: UserDefaults.Keys.hasSeenOnboarding),
//      let viewController = OnboardingSheetViewController(configuration: .activity)
//   {
//       viewController.additionalSafeAreaInsets.top = 3
//       viewController.sheetPresentationController?.prefersGrabberVisible = false
//       viewController.sheetPresentationController?.detents = [.large()]
//       viewController.isModalInPresentation = true
//       present(viewController, animated: true)
//   }
// }
// ```

import UIKit

class OnboardingSheetViewController: BackgroundStyleController, UIScrollViewDelegate {
    // MARK: - Private Properties
    private var continueButton: UIButton!
    private var titleLabel: UILabel!
    private var stackView: UIStackView!
    private var scrollView: ScrollView!
    private var visualEffectView: UIVisualEffectView!
    private var configuration: Configuration!
    
    // MARK: - init(type:)
    init?(configuration: Configuration) {
        self.configuration = configuration
        if configuration.presented {
            return nil
        }
        super.init(nibName: nil, bundle: nil)
        setupVisualEffectView()
        setupViewController()
        setupContinueButton()
        setupScrollView()
        setupStackView()
        setupTitleLabel()
        setupDetails()
    }
    
    // MARK: - init?(coder:)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupViewController() {
        backgroundStyle = .none
        view.backgroundColor = .systemBackground
    }
    
    private func setupVisualEffectView() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.effect = UIBlurEffect(style: .systemMaterial)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(visualEffectView)
        
        NSLayoutConstraint.activate([
            visualEffectView.heightAnchor.constraint(equalToConstant: 120),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContinueButton() {
        continueButton = UIButton(type: .system)
        continueButton.configuration = .borderedProminent()
        continueButton.configuration?.cornerStyle = .large
        continueButton.configuration?.titleAlignment = .center
        continueButton.configuration?.baseBackgroundColor = .systemBlue
        continueButton.setTitle("Continue", for: .normal)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        visualEffectView.contentView.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -24),
            continueButton.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor, constant: -15)
        ])
    }
    
    private func setupScrollView() {
        scrollView = ScrollView()
        scrollView.clipsToBounds = true
        scrollView.delaysContentTouches = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self

        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: visualEffectView.topAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -25),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 44),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -50)
        ])
    }
    
    private func setupTitleLabel() {
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        let font = UIFont.preferredFont(forTextStyle: .largeTitle, weight: .bold)
        titleLabel.attributedText = NSAttributedString.attributedStringWithBicolor(string: self.configuration.title, targetSubstring: "ShootingDapp", bicolor: (.label, .systemBlue), font: font)
        
        stackView.addArrangedSubview(titleLabel)
        
        let spacer = UIView()
        spacer.backgroundColor = .clear
        
        stackView.addArrangedSubview(spacer)
        
        NSLayoutConstraint.activate([
            spacer.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupDetails() {
        for item in configuration.onboardingItems {
            let view = DetailView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.title = item.title
            view.subtitle = item.subtitle
            view.image = item.image
            view._tintColor = .systemBlue
            stackView.addArrangedSubview(view)
        }
    }

    // MARK: - continueButtonTapped(_ sender:)
    @objc private func continueButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let boundsHeight = scrollView.bounds.size.height

        if offsetY + boundsHeight >= contentHeight {
            visualEffectView.effect = .none
        }
        else {
            visualEffectView.effect = UIBlurEffect(style: .systemMaterial)
        }
    }
}

