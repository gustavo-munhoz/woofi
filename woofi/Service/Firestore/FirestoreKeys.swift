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
        static let profileImageUrl = "profileImageUrl"
        
        struct Stats {
            static let title = "stats"
            static let walk = "walk"
            static let feed = "feed"
            static let brush = "brush"
            static let bath = "bath"
            static let vet = "vet"
        }
    }
    
    struct Pets {
        private init() {}
        
        static let collectionTitle = "pets"
        static let createdAt = "createdAt"
        static let groupID = "groupID"
    }
}
