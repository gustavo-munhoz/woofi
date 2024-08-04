//
//  Session.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import Foundation
import Combine
import UIKit

class Session {
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = Session()

    private init() { }
    
    var cachedUsers: CurrentValueSubject<[User], Never> = CurrentValueSubject([])
    
    var currentUser: User? {
        didSet {
            guard let id = currentUser?.id else {
                UserDefaults.standard.resetUserId()
                return
            }
            UserDefaults.standard.saveUserId(id)
        }
    }
    
    func setup() async -> Bool {
        if let uid = UserDefaults.standard.loadUserId() {
            do {
                let user = try await FirestoreService.shared.fetchUser(for: uid)
                self.currentUser = user
                return true
                
            } catch {
                print("Failed to fetch user in Session: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
    
    func signOut() {
        currentUser = nil
    }
}
