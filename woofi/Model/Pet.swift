//
//  Pet.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import Foundation
import UIKit

class Pet: Hashable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let picture: UIImage?
    var tasks: [PetTaskGroup]
    
    init(id: String, name: String, breed: String, age: String, picture: UIImage? = nil, tasks: [PetTaskGroup] = []) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.picture = picture
        self.tasks = tasks
    }
    
    static func ==(_ lhs: Pet, _ rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
