//
//  InviteView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 23/05/24.
//

import UIKit

class InviteView: UIView {
    
    // TODO: Localize texts
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Invite Others"
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        
        let customFd = fd.addingAttributes([
            .traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold
            ]
        ])
        
        label.font = UIFont(descriptor: customFd, size: .zero)
        
        
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .primary
        return label
    }()
    
    let tutorialLabel: UILabel = {
        let label = UILabel()
        label.text = "Here's how you can invite others to join your group."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .primary
        return label
    }()
    
    let sendButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Send Invite"
        config.baseBackgroundColor = .systemBlue
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
        addSubview(tutorialLabel)
        addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            tutorialLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tutorialLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tutorialLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            sendButton.topAnchor.constraint(equalTo: tutorialLabel.bottomAnchor, constant: 20),
            sendButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

