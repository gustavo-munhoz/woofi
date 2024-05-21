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

        // Tarefas Diárias
        let walkMorning = PetTaskInstance(label: "Passeio Manhã", completed: true, completedBy: user1)
        let walkAfternoon = PetTaskInstance(label: "Passeio Tarde", completed: true, completedBy: user2)
        let walkEvening = PetTaskInstance(label: "Passeio Noite")
        
        let feedMorning = PetTaskInstance(label: "Refeição Manhã", completedBy: user1)
        let feedEvening = PetTaskInstance(label: "Refeição Noite", completedBy: user2)
        
        let walkTaskGroup = PetTaskGroup(task: .walk, frequency: .daily, instances: [walkMorning, walkAfternoon, walkEvening])
        let feedTaskGroup = PetTaskGroup(task: .feed, frequency: .daily, instances: [feedMorning, feedEvening])
        
        // Tarefas Semanais
        let brushTaskGroup = PetTaskGroup(task: .brush, frequency: .weekly, instances: [
            PetTaskInstance(label: "Escovação", completedBy: user1)
        ])
        
        // Tarefas Mensais
        let bathFirst = PetTaskInstance(label: "Banho 1", completedBy: user1)
        let bathSecond = PetTaskInstance(label: "Banho 2", completedBy: user2)
        
        let bathTaskGroup = PetTaskGroup(task: .bath, frequency: .monthly, instances: [bathFirst, bathSecond])
        
        let vetTaskGroup = PetTaskGroup(task: .vet, frequency: .monthly, instances: [
            PetTaskInstance(label: "Consulta Veterinária", completedBy: user2)
        ])
        
        return Pet(
            id: UUID().uuidString,
            name: "Skippy",
            breed: "Schipperke",
            age: "1 ano",
            picture: UIImage(named: "skippy"),
            tasks: [walkTaskGroup, feedTaskGroup, brushTaskGroup, bathTaskGroup, vetTaskGroup]
        )
    }
}
