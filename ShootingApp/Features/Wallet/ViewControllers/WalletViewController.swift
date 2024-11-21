//
//  WalletViewController.swift
//  ShootingApp
//
//  Created by Jose on 21/11/2024.
//

import UIKit
import Combine

final class WalletViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = WalletViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
