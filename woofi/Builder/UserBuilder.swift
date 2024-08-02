//
//  UserBuilder.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 11/07/24.
//

import UIKit

class UserBuilder {
    private(set) var userId: String?
    private(set) var username: String = "User"
    private(set) var biography: String? = ""
    private(set) var email: String? = ""
    private(set) var groupID: String = UUID().uuidString
    private(set) var profilePicture: UIImage? = UIImage(systemName: "person.crop.circle")!
    
    enum Error: Swift.Error {
        case missingId
    }
    
    func setId(_ id: String) {
        self.userId = id
    }
    
    func setUsername(_ value: String) {
        self.username = value
    }
    
    func setBiography(_ value: String) {
        self.biography = value
    }
    
    func setEmail(_ value: String) {
        self.email = value
    }
    
    func setGroupID(_ value: String) {
        self.groupID = value
    }
    
    func setProfilePicture(_ image: UIImage) {
        self.profilePicture = image
    }
    
    func build() throws -> User {
        guard let id = userId else { throw Error.missingId }
        
        let user = User(
            id: id,
            username: username,
            bio: biography,
            email: email,
            groupID: groupID
        )
        
        if let image = self.profilePicture {
            user.setProfilePicture(image)
        }
        
        return user
    }
}
