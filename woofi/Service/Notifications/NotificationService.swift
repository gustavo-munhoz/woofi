//
//  NotificationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 01/07/24.
//

import FirebaseFunctions

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    private let functions = Functions.functions()

    func sendTaskCompletedNotification(toGroupID groupID: String, byUserID userID: String, taskType: TaskType, petName: String) {
        let username = Session.shared.currentUser?.username ?? "Someone"
        let message = NotificationFactory.createTaskCompletedMessage(username: username, taskType: taskType, petName: petName)

        let data: [String: Any] = [
            "groupID": groupID,
            "userID": userID,
            "title": message.0,
            "body": message.1
        ]

        functions.httpsCallable("sendTaskCompletedNotification").call(data) { result, error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully")
            }
        }
    }
}
