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
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    var onSignUpSuccess: ((UserId) -> Void)?
    var onSignUpFailure: ((Error) -> Void)?
    
    private var lastAuthType: AuthenticationType?
    private(set) var shouldSkipSetupProfilePublisher = PassthroughSubject<Bool, Never>()
    
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
                onSignUpFailure?(error)
            }
        }
    }
    
    func signUpWithGoogle(viewControllerRef vc: UIViewController) {
        lastAuthType = .googleLogin
        
        Task {
            do {
                let authResult = try await AuthenticationService.shared.loginUser(withGoogleForm: vc)
                
                print("User signed in with Google: \(authResult.user.uid)")
                onSignUpSuccess?(authResult.user.uid)
                
            } catch {
                print("Error signing in with google: \(error.localizedDescription)")
                onSignUpFailure?(error)
            }
        }
    }
    
    func signUpWithApple() {
        lastAuthType = .appleSignIn
        
        AuthenticationService.shared.signInWithApple { result in
            switch result {
            case .success(let userId):
                print("User signed in with Apple: \(userId)")
                self.onSignUpSuccess?(userId)
                
            case .failure(let failure):
                print("Error signing in with Apple: \(failure.localizedDescription)")
                self.onSignUpFailure?(failure)
                
            }
        }
    }
    
    // MARK: - Handling user already exists
    
    func handleUserAlreadyExists(id: UserId) {
        guard lastAuthType == .googleLogin || lastAuthType == .appleSignIn else { return }
        
        Task {
            do {
                guard let user = await fetchUserFromFirebase(id: id) else { return }
                
                Session.shared.currentUser = user                
                shouldSkipSetupProfilePublisher.send(true)
            }
        }
    }
}

extension RegisterViewModel {
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
}
