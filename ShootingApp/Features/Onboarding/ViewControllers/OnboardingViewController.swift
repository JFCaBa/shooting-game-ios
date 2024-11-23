//
//  OnboardingViewController.swift
//  ShootingApp
//
//  Created by Jose on 22/11/2024.
//

import Combine
import UIKit

final class OnboardingViewController: UIViewController {
    private lazy var containerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect & Earn"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Link MetaMask to collect rewards for your achievements in the game"
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var walletButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Connect MetaMask", for: .normal)
        button.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("Skip", for: .normal)
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private let web3Service = Web3Service.shared
    private let viewModel: OnboardingViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - init(viewModel:)
    
    init(viewModel: OnboardingViewModel) {
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
        setupWalletObserver()
    }
    
    // MARK: - setupBindings()
    
    private func setupBindings() {
        viewModel.$showMetaMaskNotInstalledError
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                if show {
                    self?.showMetaMaskNotInstalledAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - setupWalletObserver()
    
    private func setupWalletObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWalletConnection),
            name: .walletConnectionChanged,
            object: nil
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(containerView)
        
        [titleLabel, descriptionLabel, walletButton, skipButton].forEach {
            containerView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    // MARK: - showMetaMaskNotInstalledAlert()
    
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
    
    private func connectToMetaMask() {
        Task {
            do {
                try await web3Service.connect()
            } catch {
                print("Error connecting to MetaMask: \(error)")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleWalletConnection() {
        viewModel.coordinator?.finishOnboarding()
    }
    
    @objc private func connectTapped() {
        viewModel.checkMetaMaskAndProceed()
        if !viewModel.showMetaMaskNotInstalledError {
            connectToMetaMask()
        }
    }
    
    @objc private func skipTapped() {
        viewModel.skip()
    }
}
