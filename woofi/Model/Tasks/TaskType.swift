//
//  TaskType.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/05/24.
//

import Foundation

/// Defines the types of Tasks that users can add to their pets.
enum TaskType: String, CaseIterable, Codable {
    case walk
    case feed
    case brush
    case bath
    case vet
    
    var localizedDescription: String {
        switch self {
        case .walk:
            return .localized(for: .taskTypeWalk)
        case .feed:
            return .localized(for: .taskTypeFeed)
        case .brush:
            return .localized(for: .taskTypeBrush)
        case .bath:
            return .localized(for: .taskTypeBath)
        case .vet:
            return .localized(for: .taskTypeVet)
        }
    }
}
