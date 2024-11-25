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
        label.isHidden = true
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
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(connectButton)
        view.addSubview(accountLabel)
        
        NSLayoutConstraint.activate([
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            connectButton.widthAnchor.constraint(equalToConstant: 200),
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            
            accountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            accountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            accountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - setupBindings()
    
    private func setupBindings() {
        viewModel.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.updateButtonState(isConnected: isConnected)
            }
            .store(in: &cancellables)
        
        viewModel.$accountAddress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                self?.updateAccountLabel(address: address)
            }
            .store(in: &cancellables)
        
        viewModel.$showMetaMaskNotInstalledError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                if show {
                    self?.showMetaMaskNotInstalledAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - setupNotifications()
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMetaMaskConnection),
            name: NSNotification.Name("MetaMaskDidConnect"),
            object: nil
        )
    }
    
    private func updateButtonState(isConnected: Bool) {
        connectButton.setTitle(isConnected ? "Disconnect MetaMask" : "Connect MetaMask", for: .normal)
    }
    
    private func updateAccountLabel(address: String?) {
        accountLabel.isHidden = address == nil
        if let address = address {
            accountLabel.text = "Connected to:\n\(address)"
        }
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
        }
    }
}
