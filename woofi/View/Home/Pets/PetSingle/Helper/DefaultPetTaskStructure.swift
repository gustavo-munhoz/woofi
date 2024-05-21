//
//  DefaultPetTaskStructure.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import Foundation

struct DefaultPetTaskStructure {
    static func dailyTasks() -> [PetTaskGroup] {
        return [
            PetTaskGroup(task: .walk, frequency: .daily, instances: [
                PetTaskInstance(label: LocalizedString.Tasks.morningWalk),
                PetTaskInstance(label: LocalizedString.Tasks.afternoonWalk),
                PetTaskInstance(label: LocalizedString.Tasks.nightWalk)
            ]),
            PetTaskGroup(task: .feed, frequency: .daily, instances: [
                PetTaskInstance(label: LocalizedString.Tasks.morningMeal),
                PetTaskInstance(label: LocalizedString.Tasks.nightMeal)
            ])
        ]
    }
    
    static func weeklyTasks() -> [PetTaskGroup] {
        return [
            PetTaskGroup(task: .brush, frequency: .weekly, instances: [
                PetTaskInstance(label: LocalizedString.Tasks.weeklyBrush)
            ])
        ]
    }
    
    static func monthlyTasks() -> [PetTaskGroup] {
        return [
            PetTaskGroup(task: .bath, frequency: .monthly, instances: [
                PetTaskInstance(label: LocalizedString.Tasks.firstBath),
                PetTaskInstance(label: LocalizedString.Tasks.secondBath)
            ]),
            PetTaskGroup(task: .vet, frequency: .monthly, instances: [
                PetTaskInstance(label: LocalizedString.Tasks.monthlyVet)
            ])
        ]
    }
}
