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
    var taskGroups: [PetTaskGroup]
    
    init(id: String, name: String, breed: String, age: String, picture: UIImage? = nil, tasks: [PetTaskGroup] = []) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.picture = picture
        self.taskGroups = tasks
    }
    
    static func ==(_ lhs: Pet, _ rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Pet {
    static func mockPet() -> Pet {
        let user1 = User(id: "1", name: "Membro 1", description: "Descrição do Membro 1")
        let user2 = User(id: "2", name: "Membro 2", description: "Descrição do Membro 2")
        
        let walkMorning = PetTaskInstance(label: "Manhã", completed: true, completedBy: user1)
        let walkAfternoon = PetTaskInstance(label: "Tarde", completed: true, completedBy: user2)
        let walkEvening = PetTaskInstance(label: "Noite")
        
        let feedMorning = PetTaskInstance(label: "Manhã", completedBy: user1)
        let feedAfternoon = PetTaskInstance(label: "Tarde", completedBy: user2)
        let feedEvening = PetTaskInstance(label: "Noite")
        
        let walkTaskGroup = PetTaskGroup(task: .walk, frequency: .daily, instances: [walkMorning, walkAfternoon, walkEvening])
        let feedTaskGroup = PetTaskGroup(task: .feed, frequency: .daily, instances: [feedMorning, feedAfternoon, feedEvening])
        
        let bathTaskGroup = PetTaskGroup(task: .bath, frequency: .weekly, instances: [
            PetTaskInstance(label: "Banho", completedBy: user1)
        ])
        
        let vetTaskGroup = PetTaskGroup(task: .distance, frequency: .monthly, instances: [
            PetTaskInstance(label: "Consulta Veterinária", completedBy: user2)
        ])
        
        return Pet(
            id: UUID().uuidString,
            name: "Skippy",
            breed: "Schipperke",
            age: "1 ano",
            picture: UIImage(named: "skippy"),
            tasks: [walkTaskGroup, feedTaskGroup, bathTaskGroup, vetTaskGroup]
        )
    }
}
