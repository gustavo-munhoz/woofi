//
//  Session.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import Foundation
import Combine

class Session {
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = Session()
    
    private init() {
        if let user = UserDefaults.standard.loadUser() {
            self.currentUser = user
        }
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
