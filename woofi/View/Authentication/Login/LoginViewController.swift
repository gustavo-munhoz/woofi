//
//  LoginViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 20/07/24.
//

import Foundation
import UIKit
import Combine

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
    
    enum AuthError: Swift.Error {
        case userNotFound
    }
    
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
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(HomeViewController(), animated: true)
                }
                
            } catch {
                print("User was not found during authentication success.")
                viewModel.handleUserNotFound(for: id)
            }
        }
    }
    
    private func handleAuthFailure(with error: Error) {
        print("Authentication failed: \(error.localizedDescription)")
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
        
        present(registerVC, animated: true)
    }
}

