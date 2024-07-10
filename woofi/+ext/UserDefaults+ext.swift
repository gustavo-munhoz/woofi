//
//  UserDefaults+ext.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 27/05/24.
//

import Foundation

extension UserDefaults {
    
    private enum Keys {
        static let currentUser = "currentUser"
    }
    
    func saveUser(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            set(data, forKey: Keys.currentUser)
            print("User saved successfully in UserDefaults. Id: \(user.id)")
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    func loadUser() -> User? {
        guard let data = data(forKey: Keys.currentUser) else { return nil }
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            print("User loaded successfully from UserDefaults. id: \(user.id)")
            return user
        } catch {
            print("Failed to load user: \(error)")
            return nil
        }
    }
    
    func removeUser() {
        print("User removed successfully from UserDefaults.")
        removeObject(forKey: Keys.currentUser)
    }
}
