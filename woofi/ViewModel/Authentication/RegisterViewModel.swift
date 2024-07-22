//
//  RegisterViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/07/24.
//

import Foundation
import Combine

class RegisterViewModel {
    @Published var isSigningUp = false
    
    @Published var email: String = ""
    @Published var password: String = ""
}
