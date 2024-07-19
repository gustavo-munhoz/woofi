//
//  ViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import UIKit
import Combine

class AuthenticationViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private var registerableProviders: [AuthenticationType] = [.googleLogin, .appleSignIn]
    
    var loginView: LoginView?
    var registerView: RegisterView?
    
    var viewModel: AuthenticationViewModel? {
        didSet {
            fillUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupSubscriptions()
        fillUI()
    }        
    
    private func setupViewModel() {
        viewModel = AuthenticationViewModel()
        
        viewModel?.onAuthenticationSuccess = { [weak self] userId in
            Task {
                do {
                    guard let self = self else { return }
                    
                    let userExists = try await FirestoreService.shared.checkIfUserExists(id: userId)
                    
                    if let authType = self.viewModel?.currentAuthType.value, self.registerableProviders.contains(authType), !userExists {
                        DispatchQueue.main.async {
                            let vc = ProfileSetupViewController()
                            vc.profileSetupView.userBuilder.setId(userId)
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        return
                    }
                    
                    let userData = try await FirestoreService.shared.fetchUserData(userId: userId)
                    
                    guard let username = userData[FirestoreKeys.Users.username] as? String else {
                        fatalError("Username not found")
                    }
                    
                    let user = User(
                        id: userId,
                        username: username,
                        bio: userData[FirestoreKeys.Users.bio] as? String,
                        groupID: userData[FirestoreKeys.Users.groupID] as! String
                    )
                    
                    Session.shared.currentUser = user
                    
                    print("Authentication successful")
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(HomeViewController(), animated: true)
                    }
                }
                catch {
                    print("Error fetching user data: \(error)")
                }
            }
        }
        
        viewModel?.onAuthenticationFailure = { [weak self] error in
            self?.viewModel?.currentAuthType.value = .login
            print("Authentication failed:", error.localizedDescription)
        }
    }
    
    // MARK: View methods
    
    private func fillUI() {
        guard isViewLoaded, let viewModel = viewModel else { return }
        
        switch viewModel.currentAuthType.value {
        case .login, .googleLogin, .appleSignIn:
            showLoginView()
                
        case .register:
            showRegisterView()
        }
    }
    
    private func showLoginView() {
        if loginView == nil {
            loginView = LoginView()
            loginView?.viewModel = viewModel
            loginView?.onGoogleButtonTap = loginWithGoogle
            loginView?.onAppleButtonTap = loginWithApple
        }

        guard let loginView = loginView else { return }

        fadeInOutToView(loginView)
        loginView.startAnimation()
    }

    private func showRegisterView() {
        if registerView == nil {
            registerView = RegisterView()
            registerView?.viewModel = viewModel
        }

        guard let registerView = registerView else { return }

        fadeInOutToView(registerView)
    }
    
    private func fadeInOutToView(_ newView: UIView) {
        self.view = newView
//        UIView.animate(withDuration: 0.15) {
//            self.view.alpha = 0
//            
//        } completion: { _ in
//            UIView.animate(withDuration: 0.15) {
//                self.view = newView
//                self.view.alpha = 1
//            }
//        }
    }    
    
    // MARK: Notifications
    
    private func setupSubscriptions() {
        viewModel?.currentAuthType
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] authType in
            switch authType {
            case .login:
                self?.showLoginView()
                    
            case .register:
                self?.showRegisterView()
                
            default:
                break
            }
        }).store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    func loginWithGoogle() {
        viewModel?.currentAuthType.value = .googleLogin
        viewModel?.performAuthentication(
            type: .googleLogin,
            viewController: self
        )
    }
    
    func loginWithApple() {
        viewModel?.currentAuthType.value = .appleSignIn
        viewModel?.performAuthentication(type: .appleSignIn)
    }
}
