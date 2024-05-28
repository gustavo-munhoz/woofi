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
    var username = CurrentValueSubject<String, Never>("")
    
    var onAuthenticationSuccess: ((String) -> Void)?
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
                case .success(let authResult):
                    self?.onAuthenticationSuccess?(authResult.user.uid)
                    
                case .failure(let error):
                    self?.onAuthenticationFailure?(error)
            }
        }
    }
    
    // MARK: - Register logic
    private func registerUser() {
        let additionalData: [String:Any] = [
            FirestoreKeys.Users.username: username.value,
            FirestoreKeys.Users.groupID: UUID().uuidString,
            FirestoreKeys.Users.bio: "Biography"
        ]
        
        AuthenticationService.shared.registerUser(withEmail: email.value, password: password.value, additionalData: additionalData) { [weak self] result in
            switch result {
                case .success(let authResult):
                    self?.onAuthenticationSuccess?(authResult.user.uid)
                    
                case .failure(let error):
                    self?.onAuthenticationFailure?(error)
            }
        }
    }
}
