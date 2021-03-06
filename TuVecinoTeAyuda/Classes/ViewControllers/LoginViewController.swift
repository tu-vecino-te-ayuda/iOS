//
//  LoginViewController.swift
//  TuVecinoTeAyuda
//
//  Created by Kiszaner on 20/03/2020.
//

import UIKit
import SwiftValidator

protocol LoginViewControllerDelegate {
    func loginViewControllerRegisterVolunteer(_ sender: LoginViewController)
    func loginViewControllerRegisterRequestor(_ sender: LoginViewController)
    func loginViewController(_ sender: LoginViewController, userLogged: User)
}

final class LoginViewController: UIViewController, AlertHandler {
    
    // MARK: - Internal properties
    
    var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: Images.background)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var loginContainerView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    var loginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = LayoutParameters.spacing
        return stackView
    }()
    
    var registerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = LayoutParameters.spacing
        return stackView
    }()
    
    var heroImageView: UIImageView = {
        let imageView = UIImageView(image: Images.hero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var userField: InputField = {
        let inputField = InputField(textFieldHeight: LayoutParameters.inputFieldHeight)
        inputField.textField.placeholder = "Teléfono o email"
        inputField.textField.textContentType = .username
        let imageView = UIImageView(image: Images.user)
        imageView.tintColor = .black
        inputField.textField.leftView = imageView
        inputField.textField.leftViewMode = .always
        return inputField
    }()
    
    var passwordField: InputField = {
        let inputField = InputField(textFieldHeight: LayoutParameters.inputFieldHeight)
        inputField.textField.placeholder = "Contraseña"
        inputField.textField.isSecureTextEntry = true
        inputField.textField.textContentType = .password
        let imageView = UIImageView(image: Images.lock)
        imageView.tintColor = .black
        inputField.textField.leftView = imageView
        inputField.textField.leftViewMode = .always
        return inputField
    }()
    
    var loginButton: Button = {
        let button = Button(buttonType: .primary)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    var volunteerButton: Button = {
        let button = Button(buttonType: .secondary)
        button.addTarget(self, action: #selector(volunteerRegisterTapped), for: .touchUpInside)
        return button
    }()
    
    var requestorButton: Button = {
        let button = Button(buttonType: .secondary)
        button.addTarget(self, action: #selector(requestorRegisterTapped), for: .touchUpInside)
        return button
    }()
    
    var delegate: LoginViewControllerDelegate?
    
    // MARK: - Private properties
    
    private let validator = Validator()
    private let viewModel: LoginViewModel
    
    // MARK: - Object lifecycle
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.registerValidationFields()
        self.setupLayout()
        self.setupViewModel()
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        title = viewModel.title
        self.requestorButton.setTitle(viewModel.requestorTitle, for: .normal)
        self.volunteerButton.setTitle(viewModel.volunteerTitle, for: .normal)
        self.loginButton.setTitle(viewModel.loginTitle, for: .normal)
        self.userField.delegate = self
        self.passwordField.delegate = self
        self.configureTapGesture()
    }
    
    private func registerValidationFields() {
        self.validator.registerField(self.userField, errorLabel: self.userField.errorLabel, rules: [
            RequiredRule(message: "Campo necesario")
        ])
        self.validator.registerField(self.passwordField, errorLabel: self.passwordField.errorLabel, rules: [
            RequiredRule(message: "Campo necesario"),
            MinLengthRule(length: 8, message: "Introduce mínimo 8 caracteres")
        ])
    }
    
    private func setupLayout() {
        self.view.addSubview(self.backgroundImageView)
        self.view.safeFit(self.backgroundImageView)
        self.view.addSubview(self.heroImageView)
        self.view.addSubview(self.loginContainerView)
        self.view.addSubview(self.registerStackView)
        
        self.loginContainerView.addSubview(self.loginStackView)
        
        self.loginStackView.addArrangedSubview(self.userField)
        self.loginStackView.addArrangedSubview(self.passwordField)
        self.loginStackView.addArrangedSubview(self.loginButton)
        self.registerStackView.addArrangedSubview(self.volunteerButton)
        self.registerStackView.addArrangedSubview(self.requestorButton)
        
        NSLayoutConstraint.activate([
            // Position the header image.
            self.heroImageView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: LayoutParameters.margin),
            self.heroImageView.topAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: LayoutParameters.margin),
            self.heroImageView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -LayoutParameters.margin),
            
            // Then, set the login container.
            self.loginContainerView.topAnchor.constraint(equalTo: self.heroImageView.bottomAnchor, constant: LayoutParameters.spacing),
            self.loginContainerView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: LayoutParameters.spacing),
            self.loginContainerView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -LayoutParameters.spacing),
            
            // Some padding from the container view to the stack view.
            self.loginStackView.leadingAnchor.constraint(equalTo: self.loginContainerView.leadingAnchor, constant: 15),
            self.loginStackView.topAnchor.constraint(equalTo: self.loginContainerView.topAnchor, constant: 20),
            self.loginContainerView.trailingAnchor.constraint(equalTo: self.loginStackView.trailingAnchor, constant: 15),
            self.loginContainerView.bottomAnchor.constraint(equalTo: self.loginStackView.bottomAnchor, constant: 20),
            
            // Adjust the size of the text fields.
            self.userField.widthAnchor.constraint(equalTo: self.loginStackView.widthAnchor),
            self.passwordField.widthAnchor.constraint(equalTo: self.loginStackView.widthAnchor),
            self.loginButton.heightAnchor.constraint(equalToConstant: LayoutParameters.buttonHeight),
            self.loginStackView.widthAnchor.constraint(equalTo: self.loginButton.widthAnchor, multiplier: 1, constant: 95),
            
            // Then, the register elements.
            self.registerStackView.topAnchor.constraint(equalTo: self.loginContainerView.bottomAnchor, constant: LayoutParameters.verticalSpacing),
            self.registerStackView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: LayoutParameters.margin),
            self.registerStackView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -LayoutParameters.margin),
            
            // Setup of the register buttons.
            self.requestorButton.widthAnchor.constraint(equalTo: self.loginButton.widthAnchor, multiplier: 1, constant: 30),
            self.volunteerButton.widthAnchor.constraint(equalTo: self.requestorButton.widthAnchor),
            self.requestorButton.heightAnchor.constraint(equalToConstant: LayoutParameters.buttonHeight),
            self.volunteerButton.heightAnchor.constraint(equalToConstant: LayoutParameters.buttonHeight),
        ])
    }
    
    private func setupViewModel() {
        viewModel.error = { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Algo ha fallado al iniciar sesión, revise el formulario e inténtelo de nuevo más tarde", buttonTitle: "Ok")
            }
        }
        
        viewModel.operationInProgress = { [weak self] inProgress in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loginButton.isEnabled = !inProgress
            }
        }
        
        viewModel.logged = { [weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.loginViewController(self, userLogged: user)
            }
        }
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleViewTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handleViewTap() {
        self.view.endEditing(true)
    }
    
    @objc
    private func loginTapped() {
        self.loginButton.endEditing(true)
        // Validate input fields
        validator.validate(self)
    }
    
    @objc
    private func requestorRegisterTapped() {
        // Go to Requesto form
        self.delegate?.loginViewControllerRegisterRequestor(self)
    }
    
    @objc
    private func volunteerRegisterTapped() {
        // Go to Requesto form
        self.delegate?.loginViewControllerRegisterVolunteer(self)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userField.textField:
            userField.validate(usingValidator: validator) { [weak self] in
                guard let self = self else { return }
                _ = self.passwordField.becomeFirstResponder()
            }
        default:
            passwordField.validate(usingValidator: validator) { [weak self] in
                guard let self = self else { return }
                _ = self.passwordField.resignFirstResponder()
            }
        }
        
        return true
    }
}

// MARK: - ValidatorDelegate

extension LoginViewController: ValidationDelegate {
    func validationSuccessful() {
        debugPrint("validation succedded")
        guard let user = userField.textField.text, let password = passwordField.textField.text else {
            return
        }
        self.viewModel.login(user: user, password: password)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        errors.forEach { (validatable, error) in
            guard let inputField = validatable as? InputField else {
                return
            }
            inputField.validationFailed(error.errorMessage)
        }
    }
}

// MARK: - Private extensions

private extension LoginViewController {
    struct LayoutParameters {
        static let spacing: CGFloat = 10.0
        static let verticalSpacing: CGFloat = 40.0
        static let margin: CGFloat = 16.0
        static let inputFieldHeight: CGFloat = 50.0
        static let buttonHeight: CGFloat = 60.0
    }
}
