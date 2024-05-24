//
//  SceneDelegate.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import UIKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Universal Link
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL{
            
            handleDynamicLink(url: url)
        }
        
        // Deeplink
        if let url = connectionOptions.urlContexts.first?.url {
            handleDynamicLink(url: url)
        }
        
        window = UIWindow(windowScene: windowScene)
        
        let rootViewController: UIViewController = AuthenticationViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            self.handleDynamicLink(url: url)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL: \(incomingURL)")
            
            DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print("Error handling dynamic link: \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
        }
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else { return }
        // Handle the incoming dynamic link
        print("Incoming dynamic link: \(url.absoluteString)")
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           components.path.contains("/invite"),
           let queryItems = components.queryItems,
           let groupID = queryItems.first(where: { $0.name == "groupID" })?.value,
           let inviterID = queryItems.first(where: { $0.name == "userID"})?.value
        {
            self.presentJoinGroupViewController(with: groupID, inviterID: inviterID)
        }
    }
    
    func handleDynamicLink(url: URL) {
        DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
            guard let dynamicLink = dynamicLink else {
                return
            }
            self.handleIncomingDynamicLink(dynamicLink)
        }
    }
    
    func presentJoinGroupViewController(with groupID: String, inviterID: String) {
        let joinGroupVC = JoinGroupViewController(groupId: groupID, inviterId: inviterID)
        
        window?.rootViewController?.present(joinGroupVC, animated: true)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

