//
//  NotificationFactory.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 01/07/24.
//

import Foundation

typealias NotificationMessage = (String, String)

final class NotificationFactory {
    static func createTaskCompletedMessage(username: String, taskType: TaskType, petName: String) -> NotificationMessage {
        var title: String
        var body: String
        
        switch taskType {
        case .walk:
            title = .localized(for: .notificationMessageWalkTitle(petName: petName))
            body = .localized(for: .notificationMessageWalkBody(username: username, petName: petName))
            
        case .feed:
            title = .localized(for: .notificationMessageFeedTitle(petName: petName))
            body = .localized(for: .notificationMessageFeedBody(username: username, petName: petName))
            
        case .bath:
            title = .localized(for: .notificationMessageBathTitle(petName: petName))
            body = .localized(for: .notificationMessageBathBody(username: username, petName: petName))
            
        case .brush:
            title = .localized(for: .notificationMessageBrushTitle(petName: petName))
            body = .localized(for: .notificationMessageBrushBody(username: username, petName: petName))
            
        case .vet:
            title = .localized(for: .notificationMessageVetTitle(petName: petName))
            body = .localized(for: .notificationMessageVetBody(username: username, petName: petName))
        }
        
        return (title, body)
    }
}
