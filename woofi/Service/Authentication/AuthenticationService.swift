//
//  AuthenticationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Firebase
import FirebaseAuth

/// Service handling user authentication logic
class AuthenticationService: AuthenticationServiceProtocol {
    
    /// Singleton instance for global access
    static let shared = AuthenticationService()
    
    private init() {}
    
    /// Logs in a user using email and password
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                
            } else if let authResult = authResult {
                completion(.success(authResult))
            }
        }
    }
    
    func registerUser(withEmail email: String, password: String, additionalData: [String:Any], completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                
            } else if let user = authResult?.user {
                var userData = additionalData
                userData[FirestoreKeys.Users.uid] = user.uid
                userData[FirestoreKeys.Users.email] = user.email
                
                FirestoreService.shared.saveUserData(userId: user.uid, data: userData) { error in
                    if let error = error {
                        completion(.failure(error))
                        
                    } else if let authResult = authResult {
                        completion(.success(authResult))
                    }
                }
            }
        }
    }
}
