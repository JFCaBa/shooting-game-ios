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
    }
    
    private func setupUI() {
        title = "Create User"
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        idLabel.font = .systemFont(ofSize: 17)
        
        [nicknameField, emailField, passwordField, confirmPasswordField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
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
        
        let content = [idLabel, nicknameField, emailField, passwordField, confirmPasswordField]
        content.forEach {
            stackView.addArrangedSubview($0)
        }
        
        view.addSubview(stackView)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
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
               self.viewModel.isValidEmail(email) &&
               self.viewModel.passwordsMatch(password, confirm)
       }
       .receive(on: DispatchQueue.main)
       .assign(to: \.isEnabled, on: saveButton)
       .store(in: &cancellables)
    }
    
    @objc private func saveButtonTapped() {
        viewModel.createUser(
            nickname: nicknameField.text ?? "",
            email: emailField.text ?? "",
            password: passwordField.text ?? "",
            confirmPassword: confirmPasswordField.text ?? ""
        )
    }
}

// Extension for UITextField publisher
extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
