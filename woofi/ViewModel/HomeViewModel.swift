//
//  HomeViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 08/05/24.
//

import Foundation
import Combine

class HomeViewModel: NSObject {
    
    var userNavigationPublisher = PassthroughSubject<User, Never>()
    
    func navigateToUserView(_ user: User) {
        userNavigationPublisher.send(user)
    }
    
}
