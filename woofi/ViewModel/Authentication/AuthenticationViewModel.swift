//
//  AuthenticationViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Foundation
import Combine
import UIKit

class AuthenticationViewModel: NSObject {
    
    // MARK: - Controlling login/register
    var currentAuthType = CurrentValueSubject<AuthenticationType, Never>(.login)
    
    func toggleCurrentAuthType() {
        if currentAuthType.value != .register {
            currentAuthType.value = .login
            
        } else {
            currentAuthType.value = .register
        }
    }
    
    // MARK: - Authentication
    var email = CurrentValueSubject<String, Never>("")
    var password = CurrentValueSubject<String, Never>("")
    var username = CurrentValueSubject<String, Never>("")
    
    var onAuthenticationSuccess: ((String) -> Void)?
    var onAuthenticationFailure: ((Error) -> Void)?
    
    /// Tries to perform authentication depending on the current selected authentication type (register or login).
    /// Will try to create an account if user is trying to register, and will try to login if user is on login view.
    func performAuthentication(type: AuthenticationType, viewController: UIViewController? = nil) {
        switch type {
        case .login:
            loginUserWithEmailAndPassword()
            
        case .googleLogin:
            guard let vc = viewController else { return }
            loginWithGoogle(withVC: vc)
            
        case .register:
            registerUser()
        }
    }
    
    
    // MARK: - Login logic
    
    private func loginUserWithEmailAndPassword() {
        Task {
            do {
                let authResult = try await AuthenticationService.shared.loginUser(
                    withEmail: email.value,
                    password: password.value
                )
                onAuthenticationSuccess?(authResult.user.uid)
                
            } catch {
                onAuthenticationFailure?(error)
            }
        }
    }
    
    private func loginWithGoogle(withVC vc: UIViewController) {
        Task {
            do {
                let authResult = try await AuthenticationService.shared.loginUser(withGoogleForm: vc)
                print("User signed in with Google: \(authResult.user.uid)")
                onAuthenticationSuccess?(authResult.user.uid)
                
            } catch {
                print("Error signing in with Google: \(error.localizedDescription)")
                onAuthenticationFailure?(error)                
            }
        }
    }
    
    private func loginWithApple() {
        
    }
    
    // MARK: - Register logic
    private func registerUser() {
        let additionalData: [String:Any] = [
            FirestoreKeys.Users.username: username.value,
            FirestoreKeys.Users.groupID: UUID().uuidString,
            FirestoreKeys.Users.bio: "Biography"
        ]
        
        Task {
            do {
                let authResult = try await AuthenticationService.shared.registerUser(
                    withEmail: email.value,
                    password: password.value,
                    additionalData: additionalData
                )
                onAuthenticationSuccess?(authResult.user.uid)
                
            } catch {
                onAuthenticationFailure?(error)
            }
        }
    }
}
