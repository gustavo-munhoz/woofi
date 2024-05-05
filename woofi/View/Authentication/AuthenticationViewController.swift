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
    }
    
    // MARK: View methods
    
    private func fillUI() {
        guard isViewLoaded, let viewModel = viewModel else { return }
        
        switch viewModel.currentAuthType.value {
            case .login:
                showLoginView()
                
            case .register:
                showRegisterView()
        }
    }
    
    private func showLoginView() {
        if loginView == nil {
            loginView = LoginView()
            loginView?.viewModel = viewModel
        }

        guard let loginView = loginView else { return }

        fadeInOutToView(loginView)
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
        UIView.animate(withDuration: 0.15) {
            self.view.alpha = 0
            
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.view = newView
                self.view.alpha = 1
            }
        }
    }

    
    // MARK: Notifications
    
    private func setupSubscriptions() {
        viewModel?.currentAuthType.sink(receiveValue: { [weak self] authType in
            DispatchQueue.main.async {
                switch authType {
                    case .login:
                        self?.showLoginView()
                        
                    case .register:
                        self?.showRegisterView()
                }
            }
        }).store(in: &cancellables)
    }
}
