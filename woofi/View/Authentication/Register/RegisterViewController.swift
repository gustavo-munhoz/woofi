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
        viewModel.shouldSkipSetupProfilePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(HomeViewController(), animated: true)
                }
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication logic
    
    enum AuthError: Int, Error {
        case userAlreadyExists
        case unknownError
        
        init(error: Error) {
            let nsError = error as NSError
            
            switch nsError.code {
            case AuthError.userAlreadyExists.rawValue:
                self = .userAlreadyExists
                
            default:
                self = .unknownError
            }
        }
    }
    
    private func handleAuthSuccess(id: UserId) {
        Task {
            do {
                let userExists = try await FirestoreService.shared.checkIfUserExists(id: id)
                if userExists { throw AuthError.userAlreadyExists }
                
                DispatchQueue.main.async { [weak self] in
                    let vc = ProfileSetupViewController()
                    vc.setUserId(id)
                    
                    print("User signed up successfully.")
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
            } catch {
                let authError = AuthError(error: error)
                switch authError {
                case .userAlreadyExists:
                    print("Error: user already exists. Will try to skip profile setup.")
                    viewModel.handleUserAlreadyExists(id: id)
                case .unknownError:
                    print("Unknown error creating user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handleAuthFailure(with error: Error) {
        print("Authentication failed with error: \(error.localizedDescription)")
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
}

