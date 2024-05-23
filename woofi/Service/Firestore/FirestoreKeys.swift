//
//  FirestoreKeys.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

/// Static keys to use in data management.
struct FirestoreKeys {
    private init() {}
    
    /// Static keys related to users.
    struct Users {
        private init() {}
        
        static let collectionTitle = "users"
        static let createdAt = "createdAt"
        static let email = "email"
        static let uid = "uid"
        static let bio = "bio"
        static let username = "username"
        static let groupID = "groupID"
    }
}
