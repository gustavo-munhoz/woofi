//
//  PetTaskGroupView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 21/05/24.
//

import UIKit
import SnapKit

class PetTaskGroupView: UICollectionViewCell {
    
    static let reuseIdentifier = "PetTaskGroup"
    
    weak var taskGroup: PetTaskGroup?
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var instancesStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fillEqually        
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(withTaskGroup taskGroup: PetTaskGroup, pet: Pet?) {
        self.taskGroup = taskGroup
        
        titleLabel.text = LocalizedString.Tasks.ofType(taskGroup.task)
        
        instancesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for instance in taskGroup.instances {
            
            let view = PetTaskInstanceView()
            view.taskInstance = instance
            view.pet = pet
            view.taskGroup = taskGroup
            view.frequency = taskGroup.frequency
            
            instancesStackView.addArrangedSubview(view)
        }
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(instancesStackView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(28)
        }
        
        instancesStackView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-14).priority(999)
        }
    }
}

