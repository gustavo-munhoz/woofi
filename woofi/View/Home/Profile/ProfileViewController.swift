//
//  ProfileViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 04/07/24.
//

import Foundation
import UIKit

class ProfileViewController: UserViewController {
        
    /// Creates a `ProfileViewController` based on `Session.shared.currentUser`.
    convenience init() {
        guard let user = Session.shared.currentUser else { fatalError("User is not authenticated.") }
        
        self.init(user: user)
    }
}
