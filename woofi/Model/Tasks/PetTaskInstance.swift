//
//  PetTaskInstance.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

/// A instance of task that can be completed. Should always be contained in a `PetTaskGroup`.
class PetTaskInstance: Hashable {
    let id: UUID
    var label: String
    var completed: Bool
    weak var completedBy: User?
    
    init(label: String, completed: Bool = false, completedBy: User? = nil) {
        self.id = UUID()
        self.label = label
        self.completed = completed
        self.completedBy = completedBy
    }
    
    static func == (lhs: PetTaskInstance, rhs: PetTaskInstance) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
