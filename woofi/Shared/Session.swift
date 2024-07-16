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
    
    private init() {
        if let user = UserDefaults.standard.loadUser() {
            self.currentUser = user
            
            if let path = currentUser?.remoteProfilePicturePath,
               let url = URL(string: path) {
                Task {
                    do {
                        let image = try await FirestoreService.shared.fetchImage(from: url)
                        currentUser?.profilePicture = image
                    } catch {
                        print("Error fetching profile picture: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    var cachedUsers: CurrentValueSubject<[User], Never> = CurrentValueSubject([])
    
    var currentUser: User? {
        didSet {
            if let user = currentUser {
                UserDefaults.standard.saveUser(user)
            }
            else {
                UserDefaults.standard.removeUser()
            }
        }
    }
}
