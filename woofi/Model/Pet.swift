//
//  Pet.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import Foundation
import Combine
import UIKit

class Pet: Hashable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let picture: UIImage?
    
    var dailyTasks: CurrentValueSubject<[PetTaskGroup], Never>
    var weeklyTasks: CurrentValueSubject<[PetTaskGroup], Never>
    var monthlyTasks: CurrentValueSubject<[PetTaskGroup], Never>
    
    init(
        id: String,
        name: String,
        breed: String,
        age: String,
        picture: UIImage? = nil
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.picture = picture
        self.dailyTasks = CurrentValueSubject(DefaultPetTaskStructure.dailyTasks())
        self.weeklyTasks = CurrentValueSubject(DefaultPetTaskStructure.weeklyTasks())
        self.monthlyTasks = CurrentValueSubject(DefaultPetTaskStructure.monthlyTasks())
    }
    
    static func == (_ lhs: Pet, _ rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
