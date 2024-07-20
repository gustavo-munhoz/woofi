//
//  LoginViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 20/07/24.
//

import Foundation
import Combine

typealias UserId = String

class LoginViewModel {
    
    // MARK: - Attributes
    
    @Published var isSigningIn = false
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    var onAuthenticationSuccess: ((UserId) -> Void)?
    var onAuthenticationFailure: ((Error) -> Void)?
    
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
        
        Task {
            isSigningIn = true
            
            do {
                let authResult = try await AuthenticationService.shared.loginUser(
                    withEmail: email,
                    password: password
                )
                
                onAuthenticationSuccess?(authResult.user.uid)
                
            } catch {
                onAuthenticationFailure?(error)
            }
            
            isSigningIn = false
        }
    }
}
