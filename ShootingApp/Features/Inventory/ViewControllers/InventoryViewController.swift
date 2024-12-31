//
//  InventoryViewController.swift
//  ShootingApp
//
//  Created by Jose on 31/12/2024.
//
/*
 // For a no data scenario
 let emptyVC = EmptyStateViewController(configuration: .noData(title: "No achievements yet"))

 // For a no connection scenario
 let emptyVC = EmptyStateViewController(configuration: .noConnection())

 // For a no results scenario
 let emptyVC = EmptyStateViewController(configuration: .noResults())

 // Or with a custom configuration
 let customConfig = EmptyStateViewController.EmptyStateConfiguration(
     image: UIImage(systemName: "star.fill"),
     title: "Custom empty state message"
 )
 let emptyVC = EmptyStateViewController(configuration: customConfig)
 */

import UIKit

final class EmptyStateViewController: BackgroundStyleController {
    // MARK: - Properties
    
    private var emptyStateConfig: EmptyStateConfiguration
    
    // MARK: - UI Components
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    init(configuration: EmptyStateConfiguration) {
        self.emptyStateConfig = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureEmptyState()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func configureEmptyState() {
        emptyStateView.configure(
            image: emptyStateConfig.image,
            title: emptyStateConfig.title
        )
    }
}

// MARK: - EmptyStateConfiguration

extension EmptyStateViewController {
    struct EmptyStateConfiguration {
        let image: UIImage?
        let title: String
        
        static func noData(title: String) -> EmptyStateConfiguration {
            EmptyStateConfiguration(
                image: UIImage(systemName: "doc.text.magnifyingglass"),
                title: title
            )
        }
        
        static func noConnection(title: String = "No internet connection") -> EmptyStateConfiguration {
            EmptyStateConfiguration(
                image: UIImage(systemName: "wifi.slash"),
                title: title
            )
        }
        
        static func noResults(title: String = "No results found") -> EmptyStateConfiguration {
            EmptyStateConfiguration(
                image: UIImage(systemName: "magnifyingglass"),
                title: title
            )
        }
    }
}
