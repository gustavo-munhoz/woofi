//
//  NotificationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 01/07/24.
//

import Foundation
import FirebaseFunctions
import os

class NotificationService {
    static let shared = NotificationService()
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: NotificationService.self)
    )
    private let functions: Functions
    
    private init() {
        functions = Functions.functions()
    }

    func sendTaskCompletedNotification(toGroupID groupID: String, byUserID userID: String, taskType: TaskType, petName: String) {
        logger.debug("Sending task notification...")
        let username = Session.shared.currentUser?.username ?? "Someone"
        let message = NotificationFactory.createTaskCompletedMessage(
            username: username,
            taskType: taskType,
            petName: petName
        )

        let data: [String: Any] = [
            "groupID": groupID,
            "userID": userID,
            "title": message.0,
            "body": message.1
        ]

        functions.httpsCallable("sendTaskCompletedNotification").call(data) { [weak self] result, error in
            if let error = error {
                self?.logger.error("Error sending notification: \(error.localizedDescription)")
            } else {
                self?.logger.info("Notification sent successfully")
            }
        }
    }
}
