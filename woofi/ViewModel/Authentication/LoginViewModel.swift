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
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    var onAuthenticationSuccess: ((UserId) -> Void)?
    var onAuthenticationFailure: ((Error) -> Void)?
    
    private var lastAuthType: AuthenticationType?
    
    private(set) var shouldSetupProfilePublisher = PassthroughSubject<UserId, Never>()
    
    // MARK: - Login logic
    
    func fetchUserFromFirebase(id: UserId) async -> User? {
        do {
            let userData = try await FirestoreService.shared.fetchUserData(userId: id)
            
            let username = userData[FirestoreKeys.Users.username] as? String ?? "User"
            let bio = userData[FirestoreKeys.Users.bio] as? String
            let groupId = userData[FirestoreKeys.Users.groupID] as? String ?? UUID().uuidString
            
            let user = User(
                id: id,
                username: username,
                bio: bio,
                groupID: groupId
            )
            
            if let profilePictureUrl = userData[FirestoreKeys.Users.profileImageUrl] as? String,
               let url = URL(string: profilePictureUrl) {
                do {
                    let image = try await FirestoreService.shared.fetchImage(from: url)
                    user.profilePicture = image
                    
                } catch {
                    print("Error fetching profile picture during authentication: \(error.localizedDescription)")
                }
            }
            
            return user
            
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
            }
            
            isSigningIn = false
        }
    }
    
    func signInWithGoogle(viewControllerRef vc: UIViewController) {
        lastAuthType = .googleLogin
        
        Task {
            do {
                let authResult = try await AuthenticationService.shared.loginUser(withGoogleForm: vc)
                
                print("User signed in with Google: \(authResult.user.uid)")
                onAuthenticationSuccess?(authResult.user.uid)
                
            } catch {
                print("Error signing in with google: \(error.localizedDescription)")
                let authError = AuthError(error: error as NSError)
                onAuthenticationFailure?(authError)
            }
        }
    }
    
    func signInWithApple() {
        lastAuthType = .appleSignIn
        
        AuthenticationService.shared.signInWithApple { result in
            switch result {
            case .success(let userId):
                print("User signed in with Apple: \(userId)")
                self.onAuthenticationSuccess?(userId)
                
            case .failure(let error):
                print("Error signing in with Apple: \(error.localizedDescription)")
                let authError = AuthError(error: error as NSError)
                self.onAuthenticationFailure?(authError)
                
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
