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
                PetTaskInstance(labelKey: .morningWalk),
                PetTaskInstance(labelKey: .afternoonWalk),
                PetTaskInstance(labelKey: .eveningWalk)
            ]),
            PetTaskGroup(task: .feed, frequency: .daily, instances: [
                PetTaskInstance(labelKey: .morningFeed),
                PetTaskInstance(labelKey: .eveningFeed)
            ])
        ]
    }
    
    static func weeklyTasks() -> [PetTaskGroup] {
        return [
            PetTaskGroup(task: .brush, frequency: .weekly, instances: [
                PetTaskInstance(labelKey: .weeklyBrush)
            ])
        ]
    }
    
    static func monthlyTasks() -> [PetTaskGroup] {
        return [
            PetTaskGroup(task: .bath, frequency: .monthly, instances: [
                PetTaskInstance(labelKey: .firstBath),
                PetTaskInstance(labelKey: .secondBath)
            ]),
            PetTaskGroup(task: .vet, frequency: .monthly, instances: [
                PetTaskInstance(labelKey: .vet)
            ])
        ]
    }
}
