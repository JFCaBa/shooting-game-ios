//
//  WalletConnectionViewController.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import Combine
import UIKit

final class WalletConnectionViewController: UIViewController {
    private let viewModel: WalletConnectionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "metamask-logo")
        return imageView
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
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Connect MetaMask", for: .normal)
        button.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("Skip", for: .normal)
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: WalletConnectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        
        [imageView, titleLabel, descriptionLabel, connectButton, skipButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            imageView.heightAnchor.constraint(equalToConstant: 100),
            connectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBindings() {
        viewModel.permissionGranted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted in
                if granted {
                    self?.viewModel.skip()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func connectButtonTapped() {
        viewModel.requestPermission()
    }
    
    @objc private func skipButtonTapped() {
        viewModel.skip()
    }
}
