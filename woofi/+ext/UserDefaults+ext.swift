//
//  UserDefaults+ext.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 27/05/24.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let uid = "uid"
    }
    
    func saveUserId(_ id: UserId) {
        set(id, forKey: Keys.uid)
    }
    
    func loadUserId() -> String? {
        string(forKey: Keys.uid)
    }
    
    func resetUserId() {
        UserDefaults.standard.removeObject(forKey: Keys.uid)
    }
}
