//
//  RegisterView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import UIKit
import SnapKit
import Combine
import Lottie
import GoogleSignIn

class RegisterView: UIView {
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    weak var viewModel: RegisterViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    var onCloseButtonTap: (() -> Void)?
    var onSignUpButtonTap: (() -> Void)?
    var onGoogleButtonTap: (() -> Void)?
    var onAppleButtonTap: (() -> Void)?
    
    private var isLoginFormValid: Bool {
        !(emailTextField.text?.isEmpty ?? true) && !(passwordTextField.text?.isEmpty ?? true)
    }
    
    // MARK: - Views
    
    private(set) lazy var dogAnimation: LottieAnimationView = {
        let view = LottieAnimationView(name: "sitting-dog-register")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.animationSpeed = 1        
        
        return view
    }()
    
    private(set) lazy var welcomeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let customFd = fd.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: UIFont.Weight.thin
        ]])
        view.font = UIFont(descriptor: customFd, size: 0)
        view.textColor = .primary
        view.text = .localized(for: .registerViewWelcome)
        
        return view
    }()
    
    private(set) lazy var headerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dogAnimation, welcomeLabel])
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
    
    private(set) lazy var signUpButton: UIButton = {
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
            .localized(for: .registerViewSignUpButton),
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        )
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(signUpButtonPress), for: .touchUpInside)
        view.isEnabled = false
        
        view.configurationUpdateHandler = { [weak self] button in
            guard let self = self, let viewModel = self.viewModel else { return }
            
            var config = button.configuration
            config?.showsActivityIndicator = viewModel.isSigningUp
            config?.attributedTitle = AttributedString(
                .localized(for: viewModel.isSigningUp ? .registerViewSigningUp : .registerViewSignUpButton),
                attributes: AttributeContainer([
                    NSAttributedString.Key.font: UIFont(descriptor: customFd, size: 0),
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ])
            )
            
            button.isEnabled = !viewModel.isSigningUp && self.isLoginFormValid
            
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
    
    private(set) lazy var googleSignUpButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(UIImage(imageKey: .googleSignUp), for: .normal)
        view.addTarget(self, action: #selector(googleButtonPress), for: .touchUpInside)
        
        return view
    }()
    
    private(set) lazy var appleSignUpButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(UIImage(imageKey: .appleSignUp), for: .normal)
        view.addTarget(self, action: #selector(appleButtonPress), for: .touchUpInside)
        
        return view
    }()
    
    private(set) lazy var dismissButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        view.setPreferredSymbolConfiguration(.init(pointSize: 30), forImageIn: .normal)
        view.tintColor = .systemGray2
        
        view.addTarget(self, action: #selector(closeButtonPress), for: .touchUpInside)
        
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
    
    @objc func closeButtonPress() {
        onCloseButtonTap?()
    }
    
    @objc func signUpButtonPress() {
        onSignUpButtonTap?()
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
        
        viewModel.$isSigningUp
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.signUpButton.setNeedsUpdateConfiguration()
            }
            .store(in: &cancellables)
    }
    
    private func setupTextFieldObservers() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        signUpButton.isEnabled = isLoginFormValid
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
        addSubview(signUpButton)
        addSubview(orSeparatorLabel)
        addSubview(googleSignUpButton)
        addSubview(appleSignUpButton)
        addSubview(dismissButton)
    }
    
    func setupConstraints() {
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(250)
        }
        
        dogAnimation.snp.makeConstraints { make in
            make.height.equalTo(160)
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
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(25)
            make.width.height.centerX.equalTo(emailTextField)
        }
        
        orSeparatorLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(15)
            make.height.equalTo(20)
            make.left.right.equalToSuperview()
        }
        
        googleSignUpButton.snp.makeConstraints { make in
            make.top.equalTo(orSeparatorLabel.snp.bottom).offset(15)
            make.width.height.centerX.equalTo(emailTextField)
        }
        
        appleSignUpButton.snp.makeConstraints { make in
            make.top.equalTo(googleSignUpButton.snp.bottom).offset(18)
            make.width.height.centerX.equalTo(emailTextField)
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension RegisterView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

