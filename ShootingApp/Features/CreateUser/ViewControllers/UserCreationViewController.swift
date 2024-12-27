//
//  UserCreationViewController.swift
//  ShootingApp
//
//  Created by Jose on 25/12/2024.
//

import Combine
import UIKit

final class UserCreationViewController: UIViewController {
    private let viewModel: UserCreationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var idLabel = UILabel()
    private lazy var nicknameField = UITextField()
    private lazy var emailField = UITextField()
    private lazy var passwordField = UITextField()
    private lazy var confirmPasswordField = UITextField()
    private lazy var saveButton = UIButton(configuration: .filled())
    private lazy var loginButton = UIButton()
    
    init(viewModel: UserCreationViewModel) {
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
        
        idLabel.text = "Player ID: \(GameManager.shared.playerId ?? "")"
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        title = "Create User"
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
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        nicknameField.placeholder = "Nickname"
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.textContentType = .emailAddress
        
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .newPassword
        
        confirmPasswordField.placeholder = "Confirm Password"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.textContentType = .newPassword
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        loginButton.setTitle("Login instead", for: .normal)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let content = [idLabel, nicknameField, emailField, passwordField, confirmPasswordField]
        content.forEach {
            stackView.addArrangedSubview($0)
        }
        
        view.addSubview(stackView)
        view.addSubview(saveButton)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self else { return }
                
                if let networkError = error as? ShootingApp.NetworkError {
                    switch networkError {
                    case .requestFailed(let innerError):
                        if let innerNetworkError = innerError as? ShootingApp.NetworkError,
                           case .alreadyRegistered = innerNetworkError {
                            showUserAlreadyExistsAlert()
                        } else {
                            showAlert(title: "Error", message: error.localizedDescription)
                        }
                    default:
                        showAlert(title: "Error", message: error.localizedDescription)
                    }
                } else {
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$token
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                viewModel.coordinator?.navigationController.popViewController(animated: true)
            }
            .store(in: &cancellables)

       // Combine all field validations
       Publishers.CombineLatest4(
           nicknameField.textPublisher,
           emailField.textPublisher,
           passwordField.textPublisher,
           confirmPasswordField.textPublisher
       )
       .map { [weak self] nickname, email, password, confirm in
           guard let self else { return false }
           return !nickname.isEmpty &&
               email.isValidEmail &&
               self.viewModel.passwordsMatch(password, confirm)
       }
       .receive(on: DispatchQueue.main)
       .assign(to: \.isEnabled, on: saveButton)
       .store(in: &cancellables)
    }
    
    private func showUserAlreadyExistsAlert() {
        let alert = UIAlertController(title: "User already exists", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { [weak self] _ in
            self?.presentLoginScreen()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        present(alert, animated: true)
    }
    
    private func presentLoginScreen() {
        viewModel.coordinator?.startLoginFlow()
    }
    
    @objc private func saveButtonTapped() {
        guard let nickName = nicknameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              let confirmPassword = confirmPasswordField.text
        else { return }
        
        viewModel.createUser(
            nickname: nickName,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
    }
    
    @objc private func loginButtonTapped() {
        viewModel.coordinator?.startLoginFlow()
    }
}
