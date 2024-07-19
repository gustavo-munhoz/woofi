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
    @Published var isSigningIn = false
    
    var currentAuthType = CurrentValueSubject<AuthenticationType, Never>(.login)
    
    func toggleCurrentAuthType() {
        let loginTypes: [AuthenticationType] = [.login, .googleLogin, .appleSignIn]
        
        if loginTypes.contains(currentAuthType.value) {
            currentAuthType.value = .register
            
        } else {
            currentAuthType.value = .login
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
            
        case .appleSignIn:
            loginWithApple()
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
        AuthenticationService.shared.signInWithApple() { result in
            switch result {
            case .success(let userId):
                print("User signed in with Apple: \(userId)")
                self.onAuthenticationSuccess?(userId)
                
            case .failure(let failure):
                print("Error signing in with Apple: \(failure.localizedDescription)")
                self.onAuthenticationFailure?(failure)
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
