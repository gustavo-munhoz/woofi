//
//  AuthenticationViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Foundation
import Combine

class AuthenticationViewModel: NSObject {
    
    // MARK: - Controlling login/register
    var currentAuthType = CurrentValueSubject<AuthenticationType, Never>(.login)
    
    func toggleCurrentAuthType() {
        currentAuthType.value = currentAuthType.value == .login ? .register : .login
    }
    
    // MARK: - Authentication
    var email = CurrentValueSubject<String, Never>("")
    var password = CurrentValueSubject<String, Never>("")
    var onAuthenticationSuccess: (() -> Void)?
    var onAuthenticationFailure: ((Error) -> Void)?
    
    /// Tries to perform authentication depending on the current selected authentication type (register or login).
    /// Will try to create an account if user is trying to register, and will try to login if user is on login view.
    func performAuthentication() {
        switch currentAuthType.value {
            case .login:
                loginUser()
                
            case .register:
                registerUser()
        }
    }
    
    
    // MARK: - Login logic
    
    private func loginUser() {
        AuthenticationService.shared.loginUser(withEmail: email.value, password: password.value) { [weak self] result in
            switch result {
                case .success():
                    self?.onAuthenticationSuccess?()
                    
                case .failure(let error):
                    self?.onAuthenticationFailure?(error)
            }
        }
    }
    
    // MARK: - Register logic
    private func registerUser() {
        
    }
}
