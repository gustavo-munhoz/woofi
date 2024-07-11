//
//  AppDelegate.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var fcmToken: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user, let fcmToken = self.fcmToken {
                Firestore.firestore()
                    .collection(FirestoreKeys.Users.collectionTitle)
                    .document(user.uid)
                    .updateData(["fcmToken": fcmToken])
                
                print("Registered fcm token in firebase: \(fcmToken)")
            }
        }

        Messaging.messaging().delegate = self
        
        setupGIDClientID()

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // Configure Firebase with APNs token
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func setupGIDClientID() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }

        print("FCM Token: \(fcmToken)")
        if let userID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userID).updateData(["fcmToken": fcmToken])
            
        } else {
            // Store FCM Token temporarily
            self.fcmToken = fcmToken
        }
    }
}
