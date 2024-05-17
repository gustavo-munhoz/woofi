//
//  PetSectionHeaderView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import UIKit
import SnapKit

class PetSectionHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "PetSectionHeaderView"
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
        
        view.font = UIFont(descriptor: boldFd, size: .zero)
        
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: "PetSectionHeaderView")
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func setup(with title: String) {
        titleLabel.text = title
    }
}

