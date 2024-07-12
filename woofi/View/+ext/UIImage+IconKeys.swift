//
//  UIImage+IconKeys.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/07/24.
//

import UIKit

extension UIImage {
    enum IconKeys: String {
        case google = "google-si-icon"
        case apple = "apple-si-icon"
    }
    
    convenience init(iconKey: IconKeys) {
        self.init(named: iconKey.rawValue)!
    }
}
