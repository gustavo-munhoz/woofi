//
//  NotificationService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 01/07/24.
//

import FirebaseFunctions

class NotificationService {
    private let functions = Functions.functions()

    func sendTaskCompletedNotification(toGroupID groupID: String, byUserID userID: String, taskLabel: String) {
        let data: [String: Any] = [
            "groupID": groupID,
            "userID": userID,
            "taskLabel": taskLabel
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
