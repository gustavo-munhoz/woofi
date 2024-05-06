//
//  RegisterView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import UIKit
import SnapKit
import Combine

class RegisterView: UIView {
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    weak var viewModel: AuthenticationViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    // MARK: Views
    
    private(set) lazy var appLogo: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "dog.circle.fill"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.tintColor = .white
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private(set) lazy var emailTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.placeholder = LocalizedString.LoginAndRegister.emailInput
        view.borderStyle = .roundedRect
        
        return view
    }()
    
    private(set) lazy var usernameTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.placeholder = LocalizedString.LoginAndRegister.usernameInput
        view.borderStyle = .roundedRect
        
        return view
    }()
    
    private(set) lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.placeholder = LocalizedString.LoginAndRegister.passwordInput
        view.borderStyle = .roundedRect
        view.isSecureTextEntry = true
        
        return view
    }()
    
    private(set) lazy var registerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.attributedTitle = AttributedString(
            LocalizedString.LoginAndRegister.registerButton,
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        )
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(registerButtonPress), for: .touchUpInside)
        return view
    }()
    
    private(set) lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.borderedTinted()
        config.baseBackgroundColor = .systemGray
        config.background.strokeColor = .white
    
        config.attributedTitle = AttributedString(
            LocalizedString.LoginAndRegister.loginButton,
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
    
    // MARK: - Actions
    
    @objc func registerButtonPress() {
        viewModel?.performAuthentication()
    }
    
    @objc func loginButtonPress() {
        viewModel?.toggleCurrentAuthType()
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        emailTextField.textPublisher
            .assign(to: \.value, on: viewModel.email)
            .store(in: &cancellables)
        
        usernameTextField.textPublisher
            .assign(to: \.value, on: viewModel.username)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .assign(to: \.value, on: viewModel.password)
            .store(in: &cancellables)
    }
    
    // MARK: - Default methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        let subviews = [
            appLogo, emailTextField, usernameTextField,
            passwordTextField, registerButton, loginButton
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
        
        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(25)
            make.height.equalTo(emailTextField)
            make.left.right.equalTo(emailTextField)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(25)
            make.height.equalTo(usernameTextField.snp.height)
            make.left.right.equalTo(usernameTextField)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(25)
            make.height.equalTo(passwordTextField.snp.height)
            make.left.right.equalTo(passwordTextField)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(25)
            make.height.equalTo(registerButton.snp.height)
            make.left.right.equalTo(registerButton)
        }
    }
}


