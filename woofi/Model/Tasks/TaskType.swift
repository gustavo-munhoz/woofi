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
            return LocalizedString.Tasks.walk
        case .feed:
            return LocalizedString.Tasks.feed
        case .bath:
            return LocalizedString.Tasks.bath
        case .brush:
            return LocalizedString.Tasks.brush
        case .vet:
            return LocalizedString.Tasks.vet
        }
    }
}
