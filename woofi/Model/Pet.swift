//
//  Pet.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import Foundation
import UIKit
import Combine

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
        picture: UIImage? = nil,
        dailyTasks: [PetTaskGroup] = [],
        weeklyTasks: [PetTaskGroup] = [],
        monthlyTasks: [PetTaskGroup] = []
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.picture = picture
        self.dailyTasks = CurrentValueSubject(dailyTasks)
        self.weeklyTasks = CurrentValueSubject(weeklyTasks)
        self.monthlyTasks = CurrentValueSubject(monthlyTasks)
    }
    
    static func == (_ lhs: Pet, _ rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Pet {
    static func mockPet() -> Pet {

        // Tarefas Diárias
        let walkMorning = PetTaskInstance(label: "Passeio Manhã")
        let walkAfternoon = PetTaskInstance(label: "Passeio Tarde")
        let walkEvening = PetTaskInstance(label: "Passeio Noite")
        
        let feedMorning = PetTaskInstance(label: "Refeição Manhã")
        let feedEvening = PetTaskInstance(label: "Refeição Noite")
        
        let dailyTasks = [
            PetTaskGroup(task: .walk, frequency: .daily, instances: [walkMorning, walkAfternoon, walkEvening]),
            PetTaskGroup(task: .feed, frequency: .daily, instances: [feedMorning, feedEvening])
        ]
        
        // Tarefas Semanais
        let weeklyTasks = [
            PetTaskGroup(task: .brush, frequency: .weekly, instances: [
                PetTaskInstance(label: "Escovação")
            ])
        ]
        
        // Tarefas Mensais
        let bathFirst = PetTaskInstance(label: "Banho 1")
        let bathSecond = PetTaskInstance(label: "Banho 2")
        
        let monthlyTasks = [
            PetTaskGroup(task: .bath, frequency: .monthly, instances: [bathFirst, bathSecond]),
            PetTaskGroup(task: .vet, frequency: .monthly, instances: [
                PetTaskInstance(label: "Consulta Veterinária")
            ])
        ]
        
        return Pet(
            id: UUID().uuidString,
            name: "Skippy",
            breed: "Schipperke",
            age: "1 ano",
            picture: UIImage(named: "skippy"),
            dailyTasks: dailyTasks,
            weeklyTasks: weeklyTasks,
            monthlyTasks: monthlyTasks
        )
    }
}
