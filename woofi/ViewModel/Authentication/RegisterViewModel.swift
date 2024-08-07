//
//  RegisterViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/07/24.
//

import Foundation
import Combine
import UIKit

class RegisterViewModel {
    
    // MARK: - Attributes
    
    @Published var isSigningUp = false
    @Published var isSigningUpWithGoogle = false
    @Published var isSigningUpWithApple = false
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    var onSignUpSuccess: ((UserId) -> Void)?
    var onSignUpFailure: ((AuthError) -> Void)?
    
    private var lastAuthType: AuthenticationType?
    private(set) var shouldSkipSetupProfilePublisher = PassthroughSubject<Void, Never>()
    private(set) var shouldShowUserAlreadyRegisteredAlert = PassthroughSubject<Void, Never>()
    
    func resetSignUps() {
        isSigningUp = false
        isSigningUpWithGoogle = false
        isSigningUpWithApple = false
    }
    // MARK: - Sign up logic
    
    func signUpUser() {
        guard !email.isEmpty, !password.isEmpty else { return }
                
        Task {
            isSigningUp = true
            lastAuthType = .register
            
            do {
                let authResult = try await AuthenticationService.shared.registerUser(
                    withEmail: email,
                    password: password,
                    additionalData: [:]
                )
                onSignUpSuccess?(authResult.user.uid)
                
            } catch {
                onSignUpFailure?(AuthError(error: error as NSError))
                isSigningUp = false
            }
        }
    }
    
    func signUpWithGoogle(viewControllerRef vc: UIViewController) {
        lastAuthType = .googleLogin
        isSigningUpWithGoogle = true
        Task {
            do {
                let authResult = try await AuthenticationService.shared.loginUser(withGoogleForm: vc)
                
                print("User signed in with Google: \(authResult.user.uid)")
                onSignUpSuccess?(authResult.user.uid)
                
            } catch {
                print("Error signing in with google: \(error.localizedDescription)")
                onSignUpFailure?(AuthError(error: error as NSError))
                isSigningUpWithGoogle = false
            }
        }
    }
    
    func signUpWithApple() {
        lastAuthType = .appleSignIn
        isSigningUpWithApple = true
        
        AuthenticationService.shared.signInWithApple { [weak self] result in
            switch result {
            case .success(let userId):
                print("User signed in with Apple: \(userId)")
                self?.onSignUpSuccess?(userId)
                
            case .failure(let error):
                print("Error signing in with Apple: \(error.localizedDescription)")
                self?.onSignUpFailure?(AuthError(error: error as NSError))                
                self?.isSigningUpWithApple = false
            }
        }
    }
    
    // MARK: - Handling user already exists
    func getLastAuthType() -> AuthenticationType? {
        return lastAuthType
    }
    
    func handleUserAlreadyExists(id: UserId) {
        guard lastAuthType == .googleLogin || lastAuthType == .appleSignIn else { 
            shouldShowUserAlreadyRegisteredAlert.send()
            return
        }
        
        Task {
            do {
                guard let user = await fetchUserFromFirebase(id: id) else { return }
                
                Session.shared.currentUser = user                
                shouldSkipSetupProfilePublisher.send()
            }
        }
    }
}

extension RegisterViewModel {
    func fetchUserFromFirebase(id: UserId) async -> User? {
        do {
            return try await FirestoreService.shared.fetchUser(for: id)
            
        } catch {
            print("Error fetching or building user from Firebase: \(error.localizedDescription)")
            return nil
        }
    }
}
