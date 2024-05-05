//
//  AuthenticationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Firebase

/// Service handling user authentication logic
class AuthenticationService: AuthenticationServiceProtocol {
    
    /// Singleton instance for global access
    static let shared = AuthenticationService()
    
    private init() {}
    
    /// Logs in a user using email and password
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                
            } else {
                completion(.success(()))
                
            }
        }
    }
}

