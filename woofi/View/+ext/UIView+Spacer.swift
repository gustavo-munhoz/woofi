//
//  UIView+Spacer.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 16/05/24.
//

import UIKit

class SpacerView: UIView {
    
    let axis: NSLayoutConstraint.Axis
    
    init(axis: NSLayoutConstraint.Axis) {
        self.axis = axis
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.setContentHuggingPriority(.fittingSizeLevel, for: axis)
        self.setContentCompressionResistancePriority(.fittingSizeLevel, for: axis)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

