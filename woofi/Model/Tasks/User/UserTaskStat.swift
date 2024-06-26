//
//  UserTaskStat.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/05/24.
//

import Foundation

/// Contains the amount of times or correspondent value that a `Task` has been completed.
class UserTaskStat: Hashable, Codable {
    var task: TaskType
    var value: Int
    
    init(task: TaskType, value: Int) {
        self.task = task
        self.value = value
    }
    
    static func == (lhs: UserTaskStat, rhs: UserTaskStat) -> Bool {
        return lhs.task == rhs.task && lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(task)
        hasher.combine(value)
    }
    
    static func createAllWithZeroValue() -> [UserTaskStat] {
        [
            .init(
                task: .walk,
                value: 0
            ),
            .init(
                task: .feed,
                value: 0
            ),
            .init(
                task: .bath,
                value: 0
            ),
            .init(
                task: .vet,
                value: 0
            )
        ]
    }
}
