//
//  AuthenticationServiceProtocol.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import FirebaseAuth

/// Protocol that defines authentication methods
protocol AuthenticationServiceProtocol {
    func loginUser(withEmail email: String, password: String) async throws -> AuthDataResult
    func registerUser(withEmail email: String, password: String, additionalData: [String:Any]) async throws -> AuthDataResult
}
