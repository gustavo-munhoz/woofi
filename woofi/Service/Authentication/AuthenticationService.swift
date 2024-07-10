//
//  AuthenticationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Firebase
import FirebaseAuth

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

