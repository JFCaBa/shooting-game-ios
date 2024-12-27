//
//  LoginViewController.swift
//  ShootingApp
//
//  Created by Jose on 26/12/2024.
//

import Combine
import UIKit

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var titleLabel = UILabel()
    private lazy var emailField = UITextField()
    private lazy var passwordField = UITextField()
    private lazy var forgotPasswordButton = UIButton()
    private lazy var loginButton = UIButton(configuration: .filled())
    private lazy var loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: LoginViewModel) {
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
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        title = "Login"
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [emailField, passwordField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        let text = "ShootingDapp"
        let attributtedText = NSAttributedString.attributedStringWithBicolor(string: text, targetSubstring: "D", bicolor: (.label, .systemRed), font: UIFont.systemFont(ofSize: 44))
        titleLabel.attributedText = attributtedText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.textContentType = .emailAddress
        emailField.autocorrectionType = .no
        
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        
        [emailField, passwordField].forEach {
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
        }
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.isEnabled = false
        
        forgotPasswordButton.setTitle("Forgot password", for: .normal)
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false

        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(loginButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 150),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self else { return }
                if let message = (error as? ShootingApp.NetworkError)?.localizedDescription {
                    if message.contains("4") {
                        showAlert(title: "Error", message: "Invalid credentials")

                    } else {
                        showAlert(title: "Error", message: "Player not found")
                    }
                }
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
        
        viewModel.$isLoginEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)
        
        viewModel.$temporaryPassword
            .receive(on: DispatchQueue.main)
            .compactMap({$0})
            .sink { [weak self] password in
                guard let self else { return }
                
                showAlert(title: "New temporary password", message: "You have received a new temporary password, you can login with it now and change it later.")
                passwordField.text = password
            }
            .store(in: &cancellables)
        
        viewModel.$loginSuccess
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                viewModel.coordinator.navigateToHome()
            }
            .store(in: &cancellables)
        
        // Combine email and password fields to enable/disable the login button
        Publishers.CombineLatest(
            emailField.textPublisher,
            passwordField.textPublisher
        )
        .map { email, password in
            return !email.isEmpty && !password.isEmpty
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.isLoginEnabled, on: viewModel)
        .store(in: &cancellables)
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        viewModel.login(email: email, password: password)
    }
    
    @objc private func forgotPasswordButtonTapped() {
        guard let email = emailField.text,
              email.isValidEmail,
              let playerId = GameManager.shared.playerId
        else {
            showAlert(title: "Error", message: "Enter a valid email")
            return
        }
        
        passwordField.text = ""
        viewModel.forgotPassword(email: email, playerId: playerId)
    }
}
