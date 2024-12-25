//
//  SettingsViewController.swift
//  ShootingApp
//
//  Created by Jose on 03/12/2024.
//

import UIKit
import Combine

final class SettingsViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    // MARK: - Initialization
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$notificationDistance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            
            var content = cell.defaultContentConfiguration()
            content.text = "Create user"
            content.secondaryText = "You will be able to create a user with a username and password"
            cell.contentConfiguration = content
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            
            var content = cell.defaultContentConfiguration()
            content.text = "Notification Distance"
            content.secondaryText = "\(Int(viewModel.notificationDistance))m"
            cell.contentConfiguration = content
            
            return cell
            
        default: // Return the App version in the last section
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            var content = cell.defaultContentConfiguration()
            content.text = "App version:"
            content.secondaryText = viewModel.versionAndBuildNumber
            cell.contentConfiguration = content
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Create a user for extra add-ones and better experience in the game."
        case 1:
            return "You'll receive notifications when players enter within this distance. A larger distance means more notifications but earlier warnings."
        default: return nil
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0: viewModel.coordinator?.showUserCreation()
        case 1: showDistanceSelector()
        default: break
        }
    }
}

// MARK: - Actions

private extension SettingsViewController {
    func showDistanceSelector() {
        let alert = UIAlertController(
            title: "Notification Distance",
            message: "Select the minimum distance to be notified of nearby players",
            preferredStyle: .actionSheet
        )
        
        [100, 500, 1000, 5000].forEach { distance in
            let action = UIAlertAction(title: "\(distance)m", style: .default) { [weak self] _ in
                self?.viewModel.updateNotificationDistance(Double(distance))
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
