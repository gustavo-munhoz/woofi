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
    
    enum CodingKeys: String, CodingKey {
        case task
        case value
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.task = try container.decode(TaskType.self, forKey: .task)
        self.value = try container.decode(Int.self, forKey: .value)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.task, forKey: .task)
        try container.encode(self.value, forKey: .value)
    }
    
    static func == (lhs: UserTaskStat, rhs: UserTaskStat) -> Bool {
        return lhs.task == rhs.task && lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(task)
        hasher.combine(value)
    }
    
    static func createAllWithZeroValue() -> [UserTaskStat] {
        return TaskType.allCases.compactMap { UserTaskStat(task: $0, value: 0) }
    }
    
    static func createFromDictionary(_ dict: [String: Int]) -> [UserTaskStat] {
        var stats = [UserTaskStat]()
        
        for (key, value) in dict {
            if let taskType = TaskType(rawValue: key) {
                stats.append(UserTaskStat(task: taskType, value: value))
            }
        }
        
        return stats.sortedByDefinedOrder()
    }
}

extension Array where Element: UserTaskStat {
    func sortedByDefinedOrder() -> [UserTaskStat] {
        let definedOrder: [TaskType] = TaskType.allCases
        let orderDict = definedOrder.enumerated().reduce(into: [TaskType: Int]()) { result, tuple in
            result[tuple.element] = tuple.offset
        }
        
        return self.sorted {
            guard let firstOrder = orderDict[$0.task],
                  let secondOrder = orderDict[$1.task] else {
                return false
            }
            return firstOrder < secondOrder
        }
    }
}
