//
//  PetTaskInstance.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

/// An instance of task that can be completed. Should always be contained in a `PetTaskGroup`.
class PetTaskInstance: Hashable, Codable {
    let id: UUID
    var label: String
    var completed: Bool
    var completedByUserWithID: String?

    init(label: String, completed: Bool = false, userID: String? = nil) {
        self.id = UUID()
        self.label = label
        self.completed = completed
        self.completedByUserWithID = userID
    }

    static func == (lhs: PetTaskInstance, rhs: PetTaskInstance) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case completed
        case completedByUserID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        completed = try container.decode(Bool.self, forKey: .completed)
        
        if let completedByUserID = try container.decodeIfPresent(String.self, forKey: .completedByUserID) {
            self.completedByUserWithID = completedByUserID
        } else {
            self.completedByUserWithID = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(completed, forKey: .completed)
        try container.encode(completedByUserWithID, forKey: .completedByUserID)
    }    
}
