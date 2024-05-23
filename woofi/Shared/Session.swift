//
//  Session.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import Foundation

class Session {
    static let shared = Session()
    
    private init() {}
    
    var currentUser: User? = User(
        id: "3qzsiH2y0QPvDDTORqxt8jO6gl03",
        username: "Johndoe",
        bio: "...",
        groupID: "0"
    )
}
