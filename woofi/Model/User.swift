//
//  User.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit

class User: Hashable {
    
    let id: String
    var username: String
    var bio: String?
    var profilePicture: UIImage?
    var groupID: String?
    
    var stats: [UserTaskStat]
    
    init(id: String, username: String, bio: String? = nil, groupID: String? = nil, profilePicture: UIImage? = nil) {
        self.id = id
        self.username = username
        self.bio = bio
        self.groupID = groupID
        self.profilePicture = profilePicture
        self.stats = UserTaskStat.createAllWithZeroValue()
    }
    
    static func ==(_ lhs: User, _ rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
