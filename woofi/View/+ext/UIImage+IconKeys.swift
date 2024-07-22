//
//  UIImage+IconKeys.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/07/24.
//

import UIKit

extension UIImage {
    enum IconKeys: String {
        case googleSignIn = "google-si-wide"
        case googleSignUp = "google-su-wide"
        case appleSignIn = "apple-si-wide"
        case appleSignUp = "apple-su-wide"
    }
    
    convenience init(iconKey: IconKeys) {
        self.init(named: iconKey.rawValue)!
    }
}
