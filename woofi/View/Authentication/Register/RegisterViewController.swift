//
//  RegisterViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/07/24.
//

import UIKit
import Combine

class RegisterViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var registerView = RegisterView()
    
    var viewModel = RegisterViewModel()
    
    weak var delegate: AuthNavigationDelegate?
    
    override func loadView() {
        view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewActions()
        setupViewModel()
        setupSubscriptions()
    }
    
    private func setupViewModel() {
        registerView.viewModel = viewModel
        viewModel.onSignUpSuccess = handleAuthSuccess(id:)
        viewModel.onSignUpFailure = handleAuthFailure(with:)
    }
    
    private func setupSubscriptions() {
        viewModel.shouldShowUserAlreadyRegisteredAlert
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.showAlertForAuthError(.userAlreadyExists)
            }
            .store(in: &cancellables)
        
        viewModel.shouldSkipSetupProfilePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.dismiss(animated: true)
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(HomeViewController(), animated: true)
                }
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication logic
    
    private func handleAuthSuccess(id: UserId) {
        Task {
            do {
                let type = viewModel.getLastAuthType()
                let userExists = try await FirestoreService.shared.checkIfUserExists(id: id)
                if userExists && type != .register {
                    throw AuthError.userAlreadyExists
                }
                var email: String?
                if type == .register { email = viewModel.email }
                
                DispatchQueue.main.async { [weak self] in
                    let vc = ProfileSetupViewController()
                    vc.setUserId(id)
                    
                    if let email = email { vc.setUserEmail(email) }
                    
                    print("User signed up successfully.")
                    self?.dismiss(animated: true) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.navigation(shouldPushProfileSetupVC: true)
                    }
                }
                
            } catch {
                let authError = AuthError(error: error as NSError)
                switch authError {
                case .userAlreadyExists:
                    print("Error: user already exists. Will try to skip profile setup.")
                    viewModel.handleUserAlreadyExists(id: id)
                default:
                    print("Unknown error creating user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleAuthFailure(with authError: AuthError) {
        guard authError != .userCancelled else { return }
        showAlertForAuthError(authError)
        
        print("Authentication failed with error: \(authError.errorMessage)")
    }
    
    // MARK: - Actions
    
    private func setupViewActions() {
        registerView.startAnimation()
        registerView.onCloseButtonTap = handleCloseButtonTap
        registerView.onSignUpButtonTap = handleSignUpTap
        registerView.onGoogleButtonTap = handleSignUpWithGoogleTap
        registerView.onAppleButtonTap = handleSignUpWithApple
    }
    
    private func handleCloseButtonTap() {
        dismiss(animated: true)
    }
    
    private func handleSignUpTap() {
        viewModel.signUpUser()
    }
    
    private func handleSignUpWithGoogleTap() {
        viewModel.signUpWithGoogle(viewControllerRef: self)
    }
    
    private func handleSignUpWithApple() {
        viewModel.signUpWithApple()
    }
    
    // MARK: - Alert logic
    
    private func showAlertForAuthError(_ error: AuthError) {
        let alert = UIAlertController(
            title: error.errorTitle,
            message: error.errorMessage,
            preferredStyle: .alert
        )
        
        if error == .userAlreadyExists {
            let signInAction = UIAlertAction(
                title: .localized(for: .authLoginButtonTitle),
                style: .default
            ) { [weak self] _ in
                self?.dismiss(animated: true)
            }
            
            alert.addAction(signInAction)
        }
        
        let dismissAction = UIAlertAction(
            title: .localized(for: .ok).uppercased(),
            style: .cancel
        )
        
        alert.addAction(dismissAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

