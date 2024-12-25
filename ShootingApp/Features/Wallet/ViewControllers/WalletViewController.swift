//
//  WalletViewController.swift
//  ShootingApp
//
//  Created by Jose on 21/11/2024.
//

import Combine
import UIKit

final class WalletViewController: UIViewController {
    // MARK: - Constants
    
    private let viewModel = WalletViewModel()
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var accountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Balance: __ SHOT"
        return label
    }()
    
    private lazy var transferableBalanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Transferable: __ SHOT"
        return label
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.setTitle("Connect MetaMask", for: .normal)
        button.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialisers
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNotifications()
        viewModel.fetchBalance()
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(connectButton)
        view.addSubview(accountLabel)
        view.addSubview(balanceLabel)
        view.addSubview(transferableBalanceLabel)
        
        NSLayoutConstraint.activate([
            // Button
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            connectButton.widthAnchor.constraint(equalToConstant: 200),
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            // Account
            accountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            accountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            accountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Balance
            balanceLabel.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 20),
            balanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            balanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Transferable
            transferableBalanceLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 8),
            transferableBalanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            transferableBalanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - setupBindings()
    
    private func setupBindings() {
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap({$0})
            .sink { [weak self] error in
                guard let self else { return }
                
                showAlert(title: "Error", message: error.localizedDescription)
            }
            .store(in: &cancellables)
        
        viewModel.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self else { return }
                
                updateButtonState(isConnected: isConnected)
            }
            .store(in: &cancellables)
        
        viewModel.$showMetaMaskNotInstalledError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let self else { return }
                
                if show {
                    showMetaMaskNotInstalledAlert()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$balance
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                guard let self else { return }
                
                balanceLabel.text = "Balance: \(balance.balance) SHOT"
                transferableBalanceLabel.text = "Transferable: \(balance.transferable) SHOT"
            }
            .store(in: &cancellables)
    }
    
    // MARK: - setupNotifications()
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMetaMaskConnection),
            name: .metamaskDidConnect,
            object: nil
        )
    }
    
    private func updateButtonState(isConnected: Bool) {
        connectButton.setTitle(isConnected ? "Disconnect MetaMask" : "Connect MetaMask", for: .normal)
    }
    
    private func showMetaMaskNotInstalledAlert() {
        let alert = UIAlertController(
            title: "MetaMask Not Installed",
            message: "MetaMask is not required, but connecting your wallet you'll get your achivements rewards. Would you like to install it?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Install", style: .default) { [weak self] _ in
            self?.viewModel.openAppStore()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func connectTapped() {
        if viewModel.isConnected {
            viewModel.disconnect()
        } else {
            Task {
                await viewModel.connect()
            }
        }
    }
    
    @objc private func handleMetaMaskConnection() {
        Task {
            await viewModel.checkConnection()
            viewModel.fetchBalance()
        }
    }
}
