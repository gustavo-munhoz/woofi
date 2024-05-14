//
//  TaskStat.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/05/24.
//

class TaskStat: Hashable {
    var task: Task
    var value: Int
    
    init(task: Task, value: Int) {
        self.task = task
        self.value = value
    }
    
    static func == (lhs: TaskStat, rhs: TaskStat) -> Bool {
        return lhs.task == rhs.task && lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(task)
        hasher.combine(value)
    }
    
    static func createAllWithZeroValue() -> [TaskStat] {
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
                task: .distance,
                value: 0
            )
        ]
    }
}
