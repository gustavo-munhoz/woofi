//
//  HeaderView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import UIKit

class HeaderView: UICollectionReusableView {
    static let reuseIdentifier = "header-reuse-identifier"
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2).withSymbolicTraits(.traitBold)!
        
        titleLabel.font = UIFont(descriptor: fd, size: 0)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
