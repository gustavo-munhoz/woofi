//
//  PaddedTextView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/07/24.
//

import UIKit

class PaddedTextView: UITextView {
    
    var textPadding = UIEdgeInsets(
        top: 10,
        left: 10,
        bottom: 10,
        right: 10
    )
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = textPadding
    }
}
