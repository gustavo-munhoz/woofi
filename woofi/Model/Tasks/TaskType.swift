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
            return String.localized(for: .taskTypeWalk)
        case .feed:
            return String.localized(for: .taskTypeFeed)
        case .brush:
            return String.localized(for: .taskTypeBrush)
        case .bath:
            return String.localized(for: .taskTypeBath)
        case .vet:
            return String.localized(for: .taskTypeVet)
        }
    }
}
