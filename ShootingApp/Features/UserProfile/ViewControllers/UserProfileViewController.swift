//
//  UserProfileViewController.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Combine
import UIKit

final class UserProfileViewController: UIViewController {
    private let viewModel: UserProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var idLabel = UILabel()
    private lazy var emailField = UITextField()
    private lazy var nicknameField = UITextField()
    private lazy var passwordField = UITextField()
    private lazy var confirmPasswordField = UITextField()
    private lazy var updateButton = UIButton(configuration: .filled())
    private lazy var loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadUserData()
        
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        title = "User Profile"
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        idLabel.font = .systemFont(ofSize: 17)
        idLabel.lineBreakMode = .byTruncatingMiddle
        
        [nicknameField, emailField, passwordField, confirmPasswordField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        emailField.placeholder = "Email"
        emailField.isEnabled = false
        emailField.backgroundColor = .systemGray6
        
        nicknameField.placeholder = "Nickname"
        
        passwordField.placeholder = "New Password (optional)"
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .newPassword
        
        confirmPasswordField.placeholder = "Confirm New Password"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.textContentType = .newPassword
        
        updateButton.setTitle("Update Profile", for: .normal)
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        let content = [idLabel, emailField, nicknameField, passwordField, confirmPasswordField]
        content.forEach {
            stackView.addArrangedSubview($0)
        }
        
        view.addSubview(stackView)
        view.addSubview(updateButton)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            updateButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.widthAnchor.constraint(equalToConstant: 200),
            updateButton.heightAnchor.constraint(equalToConstant: 44),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
            .store(in: &cancellables)
        
        viewModel.$success
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showAlert(title: "Success", message: message)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$userData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userData in
                self?.idLabel.text = "Player ID: \(GameManager.shared.playerId ?? "")"
                self?.emailField.text = userData?.details?.email
                self?.nicknameField.text = userData?.details?.nickName
            }
            .store(in: &cancellables)
            
        // Combine nickname and password validations
        Publishers.CombineLatest3(
            nicknameField.textPublisher,
            passwordField.textPublisher,
            confirmPasswordField.textPublisher
        )
        .map { [weak self] nickname, password, confirm in
            guard let self else { return false }
            
            // Always require nickname
            guard !nickname.isEmpty else { return false }
            
            // If password field is empty, allow update (only nickname change)
            if password.isEmpty && confirm.isEmpty {
                return true
            }
            
            // If password is being changed, validate match
            return self.viewModel.passwordsMatch(password, confirm)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.isEnabled, on: updateButton)
        .store(in: &cancellables)
    }
    
    @objc private func updateButtonTapped() {
        guard let nickname = nicknameField.text else { return }
        let password = passwordField.text
        let confirmPassword = confirmPasswordField.text
        
        viewModel.updateProfile(
            nickname: nickname,
            password: password,
            confirmPassword: confirmPassword
        )
    }
}
