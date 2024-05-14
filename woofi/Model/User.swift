//
//  User.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit

class User: Hashable {
    
    let id: String
    var name: String
    var description: String
    var profilePicture: UIImage?
    
    var stats: [UserTaskStat]
    
    init(id: String, name: String, description: String, profilePicure: UIImage? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.profilePicture = profilePicure
        
        self.stats = UserTaskStat.createAllWithZeroValue()
    }
    
    static func ==(_ lhs: User, _ rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
