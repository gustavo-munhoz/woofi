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
            title = "\(petName) walk completed!"
            body = "\(username) has just walked with \(petName)."
            
        case .feed:
            title = "\(petName) fed!"
            body = "\(username) has just fed \(petName)."
            
        case .bath:
            title = "\(petName) bath completed!"
            body = "\(username) has just given \(petName) a bath."
            
        case .brush:
            title = "\(petName) brushed!"
            body = "\(username) has just brushed \(petName)."
            
        case .vet:
            title = "\(petName) vet visit done!"
            body = "\(username) has just taken \(petName) to the vet."
        }
        
        return (title, body)
    }
}
