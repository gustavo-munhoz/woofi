//
//  AuthenticationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit

class AuthenticationService: AuthenticationServiceProtocol {
    
    /// Singleton instance for global access
    static let shared = AuthenticationService()
    
    private init() {}
    
    /// Logs in a user using email and password
    func loginUser(withEmail email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw error
        }
    }
    
    /// Logs in a user with Google Auth.
    func loginUser(withGoogleForm viewController: UIViewController) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let signInResult = signInResult else {
                        continuation.resume(throwing: NSError(
                            domain: "dev.mnhz.woofy",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In failed."]
                        ))
                        return
                    }
                    
                    guard let idToken = signInResult.user.idToken?.tokenString else {
                        continuation.resume(throwing: NSError(
                            domain: "dev.mnhz.woofy",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In authentication failed"]
                        ))
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: signInResult.user.accessToken.tokenString
                    )
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            
                        } else if let authResult = authResult {
                            continuation.resume(returning: authResult)
                        }
                    }
                }
            }
        }
    }
    
    func registerUser(withEmail email: String, password: String, additionalData: [String: Any]) async throws -> AuthDataResult {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            var userData = additionalData
            userData[FirestoreKeys.Users.uid] = authResult.user.uid
            userData[FirestoreKeys.Users.email] = authResult.user.email
            
            try await FirestoreService.shared.saveUserData(userId: authResult.user.uid, data: userData)
            return authResult
        } catch {
            throw error
        }
    }
}
