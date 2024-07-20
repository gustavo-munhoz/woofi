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
        loginView.startAnimation()
    }
    
    // MARK: - Authentication logic
    
    enum AuthError: Swift.Error {
        case userNotFound
    }
    
    private func setupViewModel() {
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
}

