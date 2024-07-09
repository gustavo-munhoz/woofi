//
//  UserViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import Foundation
import Combine

class UserViewModel: NSObject {
    var user: User
    
    private(set) var userPublisher = PassthroughSubject<User, Never>()
    
    init(user: User) {
        self.user = user
    }
        
    func updateUser(username: String?, bio: String?) {
        guard let name = username, let bio = bio else { return }
        
        user.username = name
        user.bio = bio
        userPublisher.send(user)
        
        FirestoreService.shared.updateUserData(userId: user.id, data: [
            FirestoreKeys.Users.username: name,
            FirestoreKeys.Users.bio: bio
        ]) { error in
            if let error = error {
                print("Error updating user: \(error.localizedDescription)")
            } else {
                print("User updated successfully")
            }
        }
    }
}
