//
//  PetTaskInstanceView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import UIKit
import SnapKit

class PetTaskInstanceView: UIView {
    
    weak var taskInstance: PetTaskInstance? {
        didSet {
            titleLabel.text = taskInstance?.label
            completedByLabel.text = taskInstance?.completedBy?.name
        }
    }
    
    private(set) lazy var completionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(systemName: "circle"), for: .normal)
        
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var completedByLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var textsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            titleLabel,
            completedByLabel,
            SpacerView(axis: .horizontal)
        ])
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
        addSubview(completionButton)
        addSubview(textsStackView)
    }
    
    private func setupConstraints() {
        completionButton.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.equalTo(24)
        }
        
        textsStackView.snp.makeConstraints { make in
            make.left.equalTo(completionButton.snp.right).offset(10)
            make.right.centerY.equalToSuperview()
            make.height.equalTo(completionButton)
        }
    }
}

