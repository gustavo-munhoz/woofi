//
//  PetTaskCollectionViewCell.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import UIKit

class PetTaskCollectionViewCell: UICollectionViewCell {
    
    var taskType: TaskType?
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFd = fd.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]
        ])
        
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var editButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(UIImage(systemName: "ellipsis.circle.fill")?
            .withTintColor(.primary, renderingMode: .alwaysOriginal), for: .normal)
        
        view.setPreferredSymbolConfiguration(.init(textStyle: .title2), forImageIn: .normal)
        
        return view
    }()
    
    private(set) lazy var titleStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, editButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        
    }
    
    private func setupConstraints() {
        
    }
}

