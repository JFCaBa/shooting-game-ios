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
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(HallOfFameCell.self, forCellReuseIdentifier: HallOfFameCell.identifier)
        table.rowHeight = UITableView.automaticDimension
        table.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.separatorInset = UIEdgeInsets(top: 0, left: 62, bottom: 0, right: 0)
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showOnboardingIfNeeded()
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
    
    private func showOnboardingIfNeeded() {
        if let viewController = OnboardingSheetViewController(configuration: .hallOfFame) {
            viewController.additionalSafeAreaInsets.top = 3
            viewController.sheetPresentationController?.prefersGrabberVisible = false
            viewController.sheetPresentationController?.detents = [.large()]
            viewController.isModalInPresentation = true
            present(viewController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension HallOfFameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.hallOfFame.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HallOfFameCell", for: indexPath) as? HallOfFameCell else {
            fatalError("Error: Missing or invalid cell")
        }
        
        cell.accessoryType = .none
        let viewModel = HallOfFameCellViewModel(elements: viewModel.hallOfFame, row: indexPath.section)
        cell.configureWith(viewModel)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HallOfFameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8 
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
}
