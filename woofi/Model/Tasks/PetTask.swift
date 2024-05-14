//
//  PetTask.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

enum TaskFrequency {
    case daily
    case weekly
    case monthly
}

class PetTask: Hashable {
    let id: String
    var task: Task
    var completed: Bool
    var date: Date
    var frequency: TaskFrequency

    init(id: String = UUID().uuidString, task: Task, completed: Bool = false, date: Date = Date(), frequency: TaskFrequency) {
        self.id = id
        self.task = task
        self.completed = completed
        self.date = date
        self.frequency = frequency
    }

    static func == (lhs: PetTask, rhs: PetTask) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
