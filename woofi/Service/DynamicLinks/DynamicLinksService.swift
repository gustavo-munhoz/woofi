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
    
    // TODO: Fix this function
    func generateDynamicLink(groupID: String, completion: @escaping (URL?) -> Void) {
        guard let link = URL(string: "https://example.page.link/invite?groupId=\(groupID)") else {
            completion(nil)
            return
        }

        let dynamicLinksDomainURIPrefix = "https://example.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
        linkBuilder?.iOSParameters?.appStoreID = "123456789" // Seu ID do App Store
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.example.android")

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
