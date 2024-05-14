//
//  PetTaskGroup.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

/// Represents a group of `TaskInstance` that can be completed with a certain frequency.
class PetTaskGroup: Hashable {
    let id: UUID
    var task: TaskType
    var frequency: TaskFrequency
    var instances: [PetTaskInstance]
    
    init(task: TaskType, frequency: TaskFrequency, instances: [PetTaskInstance] = []) {
        self.id = UUID()
        self.task = task
        self.frequency = frequency
        self.instances = instances
    }
    
    static func == (lhs: PetTaskGroup, rhs: PetTaskGroup) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

