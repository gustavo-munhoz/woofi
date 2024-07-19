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
                PetTaskInstance(label: .localized(for: .taskDailyMorningWalk)),
                PetTaskInstance(label: .localized(for: .taskDailyAfternoonWalk)),
                PetTaskInstance(label: .localized(for: .taskDailyEveningWalk))
            ]),
            PetTaskGroup(task: .feed, frequency: .daily, instances: [
                PetTaskInstance(label: .localized(for: .taskDailyMorningMeal)),
                PetTaskInstance(label: .localized(for: .taskDailyEveningMeal))
            ])
        ]
    }
    
    static func weeklyTasks() -> [PetTaskGroup] {
        return [
            PetTaskGroup(task: .brush, frequency: .weekly, instances: [
                PetTaskInstance(label: .localized(for: .taskWeeklyBrush))
            ])
        ]
    }
    
    static func monthlyTasks() -> [PetTaskGroup] {
        return [
            PetTaskGroup(task: .bath, frequency: .monthly, instances: [
                PetTaskInstance(label: .localized(for: .taskMonthlyBathFirst)),
                PetTaskInstance(label: .localized(for: .taskMonthlyBathSecond))
            ]),
            PetTaskGroup(task: .vet, frequency: .monthly, instances: [
                PetTaskInstance(label: .localized(for: .taskMonthlyVet))
            ])
        ]
    }
}
