//
//  PetTaskGroup.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

/// Represents a group of `TaskInstance` that can be completed with a certain frequency.
class PetTaskGroup: Hashable, Codable {
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
    
    // Conformidade com o protocolo Codable
    enum CodingKeys: String, CodingKey {
        case id
        case task
        case frequency
        case instances
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        task = try container.decode(TaskType.self, forKey: .task)
        frequency = try container.decode(TaskFrequency.self, forKey: .frequency)
        instances = try container.decode([PetTaskInstance].self, forKey: .instances)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(task, forKey: .task)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(instances, forKey: .instances)
    }
}
