//
//  AuthenticationServiceProtocol.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

/// Protocol that defines authentication methods
protocol AuthenticationServiceProtocol {
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}
