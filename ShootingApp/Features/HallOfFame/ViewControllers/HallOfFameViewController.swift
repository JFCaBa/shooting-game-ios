//
//  HallOfFameViewController.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import UIKit
import Combine

final class HallOfFameViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: HallOfFameViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - init(viewModel:)
    
    init(viewModel: HallOfFameViewModel) {
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
        viewModel.fetchTopPlayers()
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Hall of Fame"
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Empty state view
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        emptyStateView.configure(
            image: UIImage(systemName: "trophy"),
            title: "No players in the Hall of Fame yet.\nKeep playing to be the first!"
        )
    }
    
    // MARK: - setupBindings()
    
    private func setupBindings() {
        viewModel.$hallOfFame
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hallOfFame in
                self?.tableView.reloadData()
                self?.emptyStateView.isHidden = !hallOfFame.isEmpty
                self?.tableView.isHidden = hallOfFame.isEmpty
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension HallOfFameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hallOfFame.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .none
        
        let player = viewModel.hallOfFame[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(player.playerID?.suffix(4) ?? "Unknown")"
        content.secondaryText = "\(player.stats.kills) kills and \(player.stats.hits) hits"
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HallOfFameViewController: UITableViewDelegate {
    // TODO: Show extended info when cell row tapped
}
