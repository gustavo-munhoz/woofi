//
//  LoginViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 20/07/24.
//

import Foundation
import Combine
import UIKit

typealias UserId = String

class LoginViewModel {
    
    // MARK: - Attributes
    
    @Published var isSigningIn = false
    @Published var isSigningInWithGoogle = false
    @Published var isSigningInWithApple = false
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    var onAuthenticationSuccess: ((UserId) -> Void)?
    var onAuthenticationFailure: ((AuthError) -> Void)?
    
    private var lastAuthType: AuthenticationType?
    
    private(set) var shouldSetupProfilePublisher = PassthroughSubject<UserId, Never>()
    
    func resetSignIns() {
        isSigningIn = false
        isSigningInWithGoogle = false
        isSigningInWithApple = false
    }
    
    // MARK: - Login logic
    
    func fetchUserFromFirebase(id: UserId) async -> User? {
        do {
            return try await FirestoreService.shared.fetchUser(for: id)
            
        } catch {
            print("Error fetching or building user from Firebase: \(error.localizedDescription)")
            return nil
        }
    }
    
    func signInWithEmailAndPassword() {
        guard !email.isEmpty, !password.isEmpty else { return }
        lastAuthType = .login
        
        Task {
            isSigningIn = true
            
            do {
                let authResult = try await AuthenticationService.shared.loginUser(
                    withEmail: email,
                    password: password
                )
                
                onAuthenticationSuccess?(authResult.user.uid)
                
            } catch {
                let authError = AuthError(error: error as NSError)
                onAuthenticationFailure?(authError)
                isSigningIn = false
            }
        }
    }
    
    func signInWithGoogle(viewControllerRef vc: UIViewController) {
        lastAuthType = .googleLogin
        isSigningInWithGoogle = true
        Task {
            do {
                let authResult = try await AuthenticationService.shared.loginUser(withGoogleForm: vc)
                
                print("User signed in with Google: \(authResult.user.uid)")
                onAuthenticationSuccess?(authResult.user.uid)
                
            } catch {
                print("Error signing in with google: \(error.localizedDescription)")
                let authError = AuthError(error: error as NSError)
                onAuthenticationFailure?(authError)
                isSigningInWithGoogle = false
            }
        }
    }
    
    func signInWithApple() {
        lastAuthType = .appleSignIn
        isSigningInWithApple = true
        
        AuthenticationService.shared.signInWithApple { [weak self] result in
            switch result {
            case .success(let userId):
                print("User signed in with Apple: \(userId)")
                self?.onAuthenticationSuccess?(userId)
                
            case .failure(let error):
                print("Error signing in with Apple: \(error.localizedDescription)")
                let authError = AuthError(error: error as NSError)
                self?.onAuthenticationFailure?(authError)
                self?.isSigningInWithApple = false
            }
        }
    }
    
    // MARK: - Handle user not existing
    
    func handleUserNotFound(for id: UserId) {
        guard lastAuthType == .googleLogin || lastAuthType == .appleSignIn else {
            return
        }
        
        shouldSetupProfilePublisher.send(id)
    }
}
