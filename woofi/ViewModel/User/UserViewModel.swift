//
//  UserViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import Foundation

class UserViewModel: NSObject {
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func updateUser(name: String?, bio: String?) {
        guard let name = name, let bio = bio else { return }
        
        user.username = name
        user.bio = bio
        
        
        func updateUser(name: String?, bio: String?) {
            guard let name = name, let bio = bio else { return }
            
            user.username = name
            user.bio = bio
            
            
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
}
