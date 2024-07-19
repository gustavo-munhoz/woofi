//
//  LoginView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import UIKit
import SnapKit
import Combine

class LoginView: UIView {
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    weak var viewModel: AuthenticationViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    var onGoogleButtonTap: (() -> Void)?
    var onAppleButtonTap: (() -> Void)?
    
    // MARK: - Views
    
    private(set) lazy var appLogo: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "dog.circle.fill"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.tintColor = .primary
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private(set) lazy var emailTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.placeholder = .localized(for: .authEmailInputLabel)
        view.borderStyle = .roundedRect
        
        return view
    }()
    
    private(set) lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.placeholder = .localized(for: .authPasswordInputLabel)
        view.borderStyle = .roundedRect
        view.isSecureTextEntry = true
        
        return view
    }()
    
    private(set) lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.attributedTitle = AttributedString(
            .localized(for: .authLoginButtonTitle),
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        )
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(loginButtonPress), for: .touchUpInside)
        
        return view
    }()
    
    private(set) lazy var registerButton: UIButton = {
        var config = UIButton.Configuration.borderedTinted()
        config.baseBackgroundColor = .systemGray
        config.background.strokeColor = .white
    
        config.attributedTitle = AttributedString(
            .localized(for: .authRegisterButtonTitle),
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.primary
            ])
        )
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(registerButtonPress), for: .touchUpInside)
        
        return view
    }()
    
    private(set) lazy var googleSignInButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(UIImage(iconKey: .google), for: .normal)
        view.addTarget(self, action: #selector(googleButtonPress), for: .touchUpInside)
        
        return view
    }()
    
    private(set) lazy var appleSignInButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(UIImage(iconKey: .apple), for: .normal)
        view.addTarget(self, action: #selector(appleButtonPress), for: .touchUpInside)
        
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        
        return view
    }()
    
    // MARK: - Actions
    
    private func setupTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func handleTap() {
        endEditing(true)
    }
    
    @objc func loginButtonPress() {
        viewModel?.performAuthentication(type: .login)
    }
    
    @objc func registerButtonPress() {
        viewModel?.toggleCurrentAuthType()
    }
    
    @objc func googleButtonPress() {
        onGoogleButtonTap?()
    }
    
    @objc func appleButtonPress() {
        onAppleButtonTap?()
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        emailTextField.textPublisher
            .assign(to: \.value, on: viewModel.email)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .assign(to: \.value, on: viewModel.password)
            .store(in: &cancellables)
    }
    
    // MARK: - Default methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubviews()
        setupConstraints()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        let subviews = [
            appLogo, emailTextField, passwordTextField,
            loginButton, registerButton, 
            googleSignInButton, appleSignInButton
        ]
        
        for view in subviews {
            addSubview(view)
        }
    }
    
    func setupConstraints() {
        appLogo.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(60)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(appLogo.snp.height)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(appLogo.snp.bottom).offset(40)
            make.height.equalTo(50)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(25)
            make.height.equalTo(emailTextField.snp.height)
            make.left.right.equalTo(emailTextField)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(25)
            make.height.equalTo(passwordTextField.snp.height)
            make.left.right.equalTo(passwordTextField)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(25)
            make.height.equalTo(loginButton.snp.height)
            make.left.right.equalTo(loginButton)
        }
        
        googleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(32)
            make.left.equalTo(registerButton)
            make.width.height.equalTo(44)
        }
        
        appleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(googleSignInButton)
            make.left.equalTo(googleSignInButton.snp.right).offset(16)
            make.width.height.equalTo(44)
        }
    }
}
