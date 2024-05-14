//
//  UIColor+InvertedBackground.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit

extension UIColor {
    
    static var primary: UIColor {
        get {
            UIColor(dynamicProvider: { $0.userInterfaceStyle == .dark ? .white : .black })
        }
    }
}
