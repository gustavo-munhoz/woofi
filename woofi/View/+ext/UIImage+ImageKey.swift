//
//  UIImage+ImageKey.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/07/24.
//

import UIKit

extension UIImage {
    enum ImageKey: String {
        case googleSignIn = "google-si-wide"
        case googleSignUp = "google-su-wide"
        case appleSignIn = "apple-si-wide"
        case appleSignUp = "apple-su-wide"
        case loadingUserCard = "user-card-loading"
        case loadingPetCard = "pet-card-loading"
        case googleIcon = "google-icon"
    }
    
    convenience init(imageKey: ImageKey) {
        self.init(named: imageKey.rawValue)!
    }
}
