//
//  DynamicLinksService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 24/05/24.
//

import Foundation
import FirebaseDynamicLinks

class DynamicLinksService {
    
    static let shared = DynamicLinksService()
    
    private init() {}
    
    func generateDynamicLink(completion: @escaping (URL?) -> Void) {
        guard let userID = Session.shared.currentUser?.id else {
            print("Missing user id.")
            return
        }
        
        guard let groupID = Session.shared.currentUser?.groupID else {
            print("Missing groupID.")
            return
        }
        
        guard let link = URL(string: "https://woofiapp.page.link/invite?userID=\(userID)&groupID=\(groupID)") else {
            completion(nil)
            return
        }

        let dynamicLinksDomainURIPrefix = "https://woofiapp.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
        linkBuilder?.iOSParameters?.appStoreID = "123456789" // Seu ID do App Store

        linkBuilder?.shorten { shortURL, warnings, error in
            if let error = error {
                print("Error generating short link: \(error)")
                completion(nil)
                return
            }
            completion(shortURL)
        }
    }
}
