//
//  Session.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import Foundation
import Combine

class Session {
    static let shared = Session()
    
    private init() {
        currentUser = UserDefaults.standard.loadUser()
    }
    
    var cachedUsers: CurrentValueSubject<[User], Never> = CurrentValueSubject([])
    
    var currentUser: User? {
        didSet {
            if let user = currentUser {
                UserDefaults.standard.saveUser(user)
            }
            else {
                UserDefaults.standard.removeUser()
            }
        }
    }
}
