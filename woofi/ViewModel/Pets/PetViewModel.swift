//
//  PetViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import Foundation
import Combine

class PetViewModel {
    var pet: Pet
    
    var dailyTaskGroups: CurrentValueSubject<[PetTaskGroup], Never> = .init([])
    var weeklyTaskGroups: CurrentValueSubject<[PetTaskGroup], Never> = .init([])
    var monthlyTaskGroups: CurrentValueSubject<[PetTaskGroup], Never> = .init([])
    
    init(pet: Pet) {
        self.pet = Pet.mockPet()
        loadTasks()
    }
    
    private func loadTasks() {
        dailyTaskGroups.send(pet.taskGroups.filter { $0.frequency == .daily })
        weeklyTaskGroups.send(pet.taskGroups.filter { $0.frequency == .weekly })
        monthlyTaskGroups.send(pet.taskGroups.filter { $0.frequency == .monthly })
    }
}
