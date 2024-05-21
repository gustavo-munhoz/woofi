//
//  Session.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import Foundation

class Session {
    static let shared = Session()
    
    private init() {}
    
    var currentUser: User? = User(id: "1", name: "Gustavo", description: "Filho")
}
