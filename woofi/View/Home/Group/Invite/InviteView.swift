//
//  InviteView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 23/05/24.
//

import UIKit

class InviteView: UIView {
    
    let tutorialLabel: UILabel = {
        let label = UILabel()
        label.text = "Here's how you can invite others to join your group."
        label.textColor = .primary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = .white
        
        addSubview(tutorialLabel)
        addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            tutorialLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            tutorialLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            tutorialLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tutorialLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            sendButton.topAnchor.constraint(equalTo: tutorialLabel.bottomAnchor, constant: 20),
            sendButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}


