//
//  LocalizedString.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

struct LocalizedString {
    
    private init() {}
    
    struct LoginAndRegister {
        private init() {}
        
        static let emailInput = String(localized: "emailInput")
        static let usernameInput = String(localized: "usernameInput")
        static let passwordInput = String(localized: "passwordInput")
        static let loginButton = String(localized: "loginButton")
        static let registerButton = String(localized: "registerButton")
        
    }
}
