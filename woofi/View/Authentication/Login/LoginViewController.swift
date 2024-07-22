//
//  LoginViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 20/07/24.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    private var loginView = LoginView()
    
    var viewModel = LoginViewModel()
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupViewActions()
        
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
//        registerVC.modal
        
        present(registerVC, animated: true)
    }
}

