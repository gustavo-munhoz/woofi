//
//  GroupViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import Foundation
import Combine

class GroupViewModel: NSObject {
    
    /// The current list of users related to the main app user.
    var users = CurrentValueSubject<[User], Never>.init([])
    
    /// Sends a signal to change the current view to a `UserView`.
    private(set) var navigateToUserPublisher = PassthroughSubject<User, Never>()
 
    override init() {
        super.init()
        loadUsers()
    }
    
    /// Loads the users from firestore.
    func loadUsers() {
        let user1 = User(id: "1", name: "Alice", description: "Description of Alice")
        let user2 = User(id: "2", name: "Bob", description: "Description of Bob")
        users.value = [user1, user2]
    }
    
    func navigateToUser(_ user: User) {
        navigateToUserPublisher.send(user)
    }
}
