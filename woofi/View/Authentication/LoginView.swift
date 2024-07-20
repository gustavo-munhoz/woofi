//
//  LoginView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import UIKit
import SnapKit
import Combine
import Lottie
import GoogleSignIn

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
    
    private(set) lazy var dogAnimation: LottieAnimationView = {
        let view = LottieAnimationView(name: "walking-dog-login")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 0.6
        
        return view
    }()
    
    private(set) lazy var welcomeBackLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let customFd = fd.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: UIFont.Weight.thin
        ]])
        view.font = UIFont(descriptor: customFd, size: 0)
        view.textColor = .primary
        view.text = .localized(for: .loginViewWelcomeBack)
        
        return view
    }()
    
    private(set) lazy var headerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dogAnimation, welcomeBackLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fill
        view.spacing = -12
        
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
        config.baseBackgroundColor = .actionGreen
        config.buttonSize = .small
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        
        let customFd = fd.addingAttributes([
            .traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold
            ]
        ])
        
        config.attributedTitle = AttributedString(
            .localized(for: .authLoginButtonTitle),
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        )
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(loginButtonPress), for: .touchUpInside)
        view.isEnabled = false
        
        return view
    }()
    
    private(set) lazy var orSeparatorLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = .preferredFont(forTextStyle: .callout)
        view.textColor = .primary.withAlphaComponent(0.5)
        view.text = .localized(for: .loginViewSeparator)
        view.textAlignment = .center
        
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
        
        return view
    }()
    
    private(set) lazy var registerLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = .preferredFont(forTextStyle: .callout)
        view.textColor = .primary
        view.textAlignment = .center
        view.text = .localized(for: .loginViewRegisterLabel)
        
        return view
    }()
    
    private(set) lazy var registerButton: UIButton = {
        var config = UIButton.Configuration.plain()
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        let customFd = fd.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold
        ]])
        
        config.attributedTitle = AttributedString(
            .localized(for: .loginViewRegisterButton),
            attributes: AttributeContainer([
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue,
                NSAttributedString.Key.underlineColor: UIColor.primary,
                NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                NSAttributedString.Key.foregroundColor: UIColor.primary
        ]))
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.configurationUpdateHandler = { sender in
            switch sender.state {
            case .highlighted, .selected:
                sender.alpha = 0.6
                
            case .normal:
                sender.alpha = 1
                
            default:
                break
            }
        }
        
        return view
    }()
    
    private(set) lazy var registerStack: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: [
                registerLabel,
                registerButton
            ]
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.axis = .horizontal
        view.alignment  = .center
        
        return view
    }()
    
    // MARK: - Actions
    
    func startAnimation() {
        dogAnimation.play()
    }
    
    private func setupTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func handleTap() {
        endEditing(true)
    }
    
    @objc func loginButtonPress() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty, !password.isEmpty
        else { return }
        
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
    
    private func setupTextFieldObservers() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let isFormValid = !(emailTextField.text?.isEmpty ?? true) && !(passwordTextField.text?.isEmpty ?? true)
        
        loginButton.isEnabled = isFormValid
    }
    
    // MARK: - Default methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubviews()
        setupConstraints()
        setupTapGesture()
        setupTextFieldObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(headerStackView)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(orSeparatorLabel)
        addSubview(googleSignInButton)
        addSubview(appleSignInButton)
        addSubview(registerStack)
    }
    
    func setupConstraints() {
        headerStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(-36)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(250)
        }
        
        dogAnimation.snp.makeConstraints { make in
            make.height.equalTo(175)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(342)
            make.height.equalTo(54)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(25)
            make.width.height.centerX.equalTo(emailTextField)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(25)
            make.width.height.centerX.equalTo(emailTextField)
        }
        
        orSeparatorLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(15)
            make.height.equalTo(20)
            make.left.right.equalToSuperview()
        }
        
        googleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(orSeparatorLabel.snp.bottom).offset(15)
            make.width.height.centerX.equalTo(emailTextField)
        }
        
        appleSignInButton.snp.makeConstraints { make in
            make.top.equalTo(googleSignInButton.snp.bottom).offset(18)
            make.width.height.centerX.equalTo(emailTextField)
        }
        
        registerStack.snp.makeConstraints { make in
            make.top.equalTo(appleSignInButton.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
    }
    
}
