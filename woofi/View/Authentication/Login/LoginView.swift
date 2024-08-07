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
    weak var viewModel: LoginViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    var onSignUpButtonTap: (() -> Void)?
    var onSignInButtonTap: (() -> Void)?
    var onGoogleButtonTap: (() -> Void)?
    var onAppleButtonTap: (() -> Void)?
    
    private var isLoginFormValid: Bool {
        !(emailTextField.text?.isEmpty ?? true) && !(passwordTextField.text?.isEmpty ?? true)
    }
    
    private var isSigningIn: Bool {
        guard let viewModel = self.viewModel else { return true }
        
        return (viewModel.isSigningIn || viewModel.isSigningInWithGoogle || viewModel.isSigningInWithApple)
    }
    
    // MARK: - Views
    
    private(set) lazy var dogAnimation: LottieAnimationView = {
        let view = LottieAnimationView(name: "walking-dog-login")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 0.6
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
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
        view.minimumScaleFactor = 0.5
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
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
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.placeholder = .localized(for: .authPasswordInputLabel)
        view.borderStyle = .roundedRect
        view.isSecureTextEntry = true
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .actionGreen
        config.buttonSize = .small
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let customFd = fd.addingAttributes([.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold
        ]])
        
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
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.configurationUpdateHandler = { [weak self] button in
            guard let self = self, let viewModel = self.viewModel else { return }
            var config = button.configuration
            config?.showsActivityIndicator = viewModel.isSigningIn
            
            button.isEnabled = !isSigningIn && self.isLoginFormValid
            
            config?.attributedTitle = AttributedString(
                .localized(for: viewModel.isSigningIn ? .loginViewSigningIn : .authLoginButtonTitle),
                attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                    NSAttributedString.Key.foregroundColor: button.isEnabled ? UIColor.white : UIColor.primary
                ])
            )
            
            button.configuration = config
        }
        
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
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .googleButtonBackground
        config.background.strokeColor = .googleButtonStroke
        config.background.strokeWidth = 1
        config.buttonSize = .small
        config.image = UIImage(imageKey: .googleIcon)
        config.imagePadding = 8
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let customFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]])
        
        config.attributedTitle = AttributedString(
            String.localized(for: .loginViewSignInWithGoogle),
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                NSAttributedString.Key.foregroundColor: UIColor.primary
        ]))
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(googleButtonPress), for: .touchUpInside)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.configurationUpdateHandler = { [weak self] button in
            guard let self = self, let viewModel = self.viewModel else { return }
            
            var config = button.configuration
            config?.showsActivityIndicator = viewModel.isSigningInWithGoogle
            config?.attributedTitle = AttributedString(
                String.localized(for: viewModel.isSigningInWithGoogle ? .loginViewSigningIn : .loginViewSignInWithGoogle),
                attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                    NSAttributedString.Key.foregroundColor: isSigningIn ? UIColor.primary : UIColor.black
            ]))
            
            button.isEnabled = !isSigningIn
            button.configuration = config
        }
        
        return view
    }()
    
    private(set) lazy var appleSignInButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .primary
        config.background.strokeColor = .systemGray
        config.background.strokeWidth = 1
        config.buttonSize = .small
        config.image = UIImage(systemName: "apple.logo")?.withTintColor(
            .systemBackground,
            renderingMode: .alwaysOriginal
        )
        config.imagePadding = 8
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let customFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]])
        
        config.attributedTitle = AttributedString(
            String.localized(for: .loginViewSignInWithApple),
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                NSAttributedString.Key.foregroundColor: UIColor.systemBackground
        ]))
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(appleButtonPress), for: .touchUpInside)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.configurationUpdateHandler = { [weak self] button in
            guard let self = self, let viewModel = self.viewModel else { return }
            
            button.isEnabled = !isSigningIn
            
            var config = button.configuration
            config?.showsActivityIndicator = viewModel.isSigningInWithApple
            config?.attributedTitle = AttributedString(
                String.localized(for: viewModel.isSigningInWithApple ? .loginViewSigningIn : .loginViewSignInWithApple),
                attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                    NSAttributedString.Key.foregroundColor: isSigningIn ? UIColor.primary : UIColor.systemBackground
            ]))
            
            button.configuration = config
        }
        
        return view
    }()
    
    private(set) lazy var registerLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = .preferredFont(forTextStyle: .callout)
        view.textColor = .primary
        view.textAlignment = .center
        view.text = .localized(for: .loginViewRegisterLabel)
        view.adjustsFontSizeToFitWidth = true
        
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
        view.addTarget(self, action: #selector(registerButtonPress), for: .touchUpInside)
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
        view.distribution = .fill
        
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
    
    @objc func registerButtonPress() {
        onSignUpButtonTap?()
    }
    
    @objc func loginButtonPress() {
        onSignInButtonTap?()
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
            .assign(to: &viewModel.$email)
        
        passwordTextField.textPublisher
            .assign(to: &viewModel.$password)

        viewModel.$isSigningIn
            .combineLatest(viewModel.$isSigningInWithGoogle, viewModel.$isSigningInWithApple)
            .map { $0 || $1 || $2 }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loginButton.setNeedsUpdateConfiguration()
                self?.googleSignInButton.setNeedsUpdateConfiguration()
                self?.appleSignInButton.setNeedsUpdateConfiguration()
            }
            .store(in: &cancellables)
    }
    
    private func setupTextFieldObservers() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        loginButton.isEnabled = isLoginFormValid
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
            make.top.equalToSuperview().inset(24)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(250).priority(.high)
            make.height.greaterThanOrEqualTo(125).priority(.required)
        }
        
        welcomeBackLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(50).priority(.required)
        }
        
        dogAnimation.snp.makeConstraints { make in
            make.height.equalTo(175).priority(.high)
            make.height.greaterThanOrEqualTo(65).priority(.required)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(342)
            make.height.equalTo(54).priority(.high)
            make.height.greaterThanOrEqualTo(44).priority(.required)
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
            make.height.equalTo(20).priority(.medium)
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
            make.width.equalToSuperview().multipliedBy(0.8)
            make.bottom.lessThanOrEqualTo(safeAreaLayoutGuide).inset(12).priority(.required)
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
