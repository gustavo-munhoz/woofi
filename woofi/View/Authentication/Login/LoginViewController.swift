//
//  LoginViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 20/07/24.
//

import Foundation
import UIKit
import Combine

protocol AuthNavigationDelegate: AnyObject {
    func navigation(shouldPushHomeVC: Bool)
    func navigateToProfileSetup(userId: String, email: String)
}

class LoginViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var loginView = LoginView()
    
    var viewModel = LoginViewModel()
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupViewActions()
        setupSubscriptions()
        
        navigationItem.title = .localized(for: .loginVCNavTitle)
        navigationItem.titleView = UIView()
    }
    
    private func setupViewActions() {
        loginView.startAnimation()
        loginView.onSignInButtonTap = handleSignInWithEmailAndPassword
        loginView.onGoogleButtonTap = handleSignInWithGoogle
        loginView.onAppleButtonTap = handleSignInWithApple
        loginView.onSignUpButtonTap = handleSignUp
    }
    
    private func setupSubscriptions() {
        viewModel.shouldSetupProfilePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] uid in
                DispatchQueue.main.async {
                    let vc = ProfileSetupViewController()
                    vc.setUserId(uid)
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Authentication logic
    
    private func setupViewModel() {
        loginView.viewModel = viewModel
        viewModel.onAuthenticationSuccess = handleAuthSuccess(id:)
        viewModel.onAuthenticationFailure = handleAuthFailure(with:)
    }
    
    private func handleAuthSuccess(id: UserId) {
        Task {
            do {
                guard let user = await viewModel.fetchUserFromFirebase(id: id) else {
                    throw AuthError.userNotFound
                }
                
                Session.shared.currentUser = user
                
                print("Authentication successful.")
                DispatchQueue.main.async { [unowned self] in
                    self.viewModel.resetSignIns()
                    self.navigationController?.pushViewController(HomeViewController(), animated: true)
                }
                
            } catch {
                print("User was not found during authentication success.")
                viewModel.handleUserNotFound(for: id)
            }
        }
    }
    
    private func handleAuthFailure(with authError: AuthError) {
        guard authError != .userCancelled else { return }
        showAlertForAuthError(authError)
        
        print("Authentication failed with error: \(authError.errorMessage)")
    }
    
    // MARK: - Actions
    
    private func handleSignInWithEmailAndPassword() {
        viewModel.signInWithEmailAndPassword()
    }
    
    private func handleSignInWithGoogle() {
        viewModel.signInWithGoogle(viewControllerRef: self)
    }
    
    private func handleSignInWithApple() {
        viewModel.signInWithApple()
    }
    
    private func handleSignUp() {
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        registerVC.delegate = self
        
        DispatchQueue.main.async { [weak self] in
            self?.present(registerVC, animated: true)
        }
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

extension LoginViewController: AuthNavigationDelegate {
    func navigation(shouldPushHomeVC: Bool) {
        if shouldPushHomeVC {
            navigationController?.pushViewController(HomeViewController(), animated: true)
        }
    }
    
    func navigateToProfileSetup(userId: String, email: String) {
        let vc = ProfileSetupViewController()
        vc.setUserId(userId)
        vc.setUserEmail(email)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
