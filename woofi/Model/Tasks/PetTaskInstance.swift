//
//  PetTaskInstance.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

/// A instance of task that can be completed. Should always be contained in a `PetTaskGroup`.
class PetTaskInstance: Hashable, Codable {
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

    // Conformidade com o protocolo Codable
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case completed
        case completedByID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        completed = try container.decode(Bool.self, forKey: .completed)
        
        if let completedByID = try container.decodeIfPresent(String.self, forKey: .completedByID) {
            Task {
                let userData = try await FirestoreService.shared.fetchUserData(userId: completedByID)
                
                guard let username = userData[FirestoreKeys.Users.username] as? String else {
                    fatalError("Username not found.")
                }
                
                let user = User(
                    id: completedByID,
                    username: username,
                    bio: userData[FirestoreKeys.Users.bio] as? String,
                    groupID: userData[FirestoreKeys.Users.groupID] as? String
                )
                
                self.completedBy = user
            }
        } else {
            self.completedBy = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(completed, forKey: .completed)
        try container.encode(completedBy?.id, forKey: .completedByID)
    }
}
