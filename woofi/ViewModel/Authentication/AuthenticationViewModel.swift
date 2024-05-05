//
//  AuthenticationViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Foundation
import Combine

class AuthenticationViewModel: NSObject {
    
    var currentAuthType = CurrentValueSubject<AuthenticationType, Never>(.login)
    
    func toggleCurrentAuthType() {
        currentAuthType.value = currentAuthType.value == .login ? .register : .login
    }
}
