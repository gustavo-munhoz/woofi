//
//  TaskType.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/05/24.
//

/// Defines the types of Tasks that users can add to their pets.
enum TaskType {
    case walk
    case feed
    case bath
    case distance
    
    var description: String {
        switch self {
        case .walk:
            return LocalizedString.Tasks.walk
        case .feed:
            return LocalizedString.Tasks.feed
        case .bath:
            return LocalizedString.Tasks.bath
        case .distance:
            return LocalizedString.Tasks.distance
        }
    }
}
