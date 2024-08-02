//
//  PetTaskInstance.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import Foundation

enum TaskLabelKey: String, Codable {
    case morningWalk
    case afternoonWalk
    case eveningWalk
    case morningFeed
    case eveningFeed
    case weeklyBrush
    case firstBath
    case secondBath
    case vet
}

/// An instance of task that can be completed. Should always be contained in a `PetTaskGroup`.
class PetTaskInstance: Hashable, Codable {
    let id: UUID
    private var labelKey: TaskLabelKey
    var label: String
    var completed: Bool
    var completedByUserWithID: String?
    
    init(labelKey: TaskLabelKey, completed: Bool = false, userID: String? = nil) {
        self.id = UUID()
        self.labelKey = labelKey
        self.completed = completed
        self.completedByUserWithID = userID
        self.label = .localized(from: labelKey)
    }

    static func == (lhs: PetTaskInstance, rhs: PetTaskInstance) -> Bool {
        lhs.id == rhs.id
        && lhs.completed == rhs.completed
        && lhs.completedByUserWithID == rhs.completedByUserWithID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case labelKey = "label"
        case completed
        case completedByUserID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        labelKey = try container.decode(TaskLabelKey.self, forKey: .labelKey)
        completed = try container.decode(Bool.self, forKey: .completed)
        
        label = .localized(from: labelKey)
        
        if let completedByUserID = try container.decodeIfPresent(String.self, forKey: .completedByUserID) {
            self.completedByUserWithID = completedByUserID
        } else {
            self.completedByUserWithID = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(labelKey, forKey: .labelKey)
        try container.encode(completed, forKey: .completed)
        try container.encode(completedByUserWithID, forKey: .completedByUserID)
    }    
}

extension String {
    fileprivate static func localized(from key: TaskLabelKey) -> String {
        switch key {
        case .morningWalk:
            return String.localized(for: .taskDailyMorningWalk)
        case .afternoonWalk:
            return String.localized(for: .taskDailyAfternoonWalk)
        case .eveningWalk:
            return String.localized(for: .taskDailyEveningWalk)
        case .morningFeed:
            return String.localized(for: .taskDailyMorningMeal)
        case .eveningFeed:
            return String.localized(for: .taskDailyEveningMeal)
        case .weeklyBrush:
            return String.localized(for: .taskWeeklyBrush)
        case .firstBath:
            return String.localized(for: .taskMonthlyBathFirst)
        case .secondBath:
            return String.localized(for: .taskMonthlyBathSecond)
        case .vet:
            return String.localized(for: .taskMonthlyVet)
        }
    }
}
