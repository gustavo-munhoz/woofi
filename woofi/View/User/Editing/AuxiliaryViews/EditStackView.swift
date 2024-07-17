//
//  EditStackView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/07/24.
//

import UIKit

class EditStackView: UIStackView {
    init(title: String, editView: UIView) {
        super.init(frame: .init(origin: .zero, size: .init(width: 1, height: 1)))
        
        let titleView: UILabel = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.text = title
            view.textColor = .primary
            let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
            let customFd = fd.addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]
            ])
            
            view.font = UIFont(descriptor: customFd, size: 0)
            return view
        }()
        
        titleView.setContentCompressionResistancePriority(.required, for: .vertical)
        editView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        addArrangedSubview(titleView)
        addArrangedSubview(editView)
//        addArrangedSubview(SpacerView(axis: .vertical))
        
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 8
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
