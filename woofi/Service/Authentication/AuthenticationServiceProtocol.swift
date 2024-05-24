//
//  AuthenticationServiceProtocol.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import FirebaseAuth

/// Protocol that defines authentication methods
protocol AuthenticationServiceProtocol {
    func loginUser(
        withEmail email: String,
        password: String,
        completion: @escaping (Result<AuthDataResult, Error>) -> Void
    )
    
    func registerUser(
        withEmail email: String,
        password: String,
        additionalData: [String:Any],
        completion: @escaping (Result<AuthDataResult, Error>) -> Void
    )
}
