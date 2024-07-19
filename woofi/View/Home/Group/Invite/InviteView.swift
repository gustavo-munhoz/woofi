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
        label.text = .localized(for: .inviteViewTitle)
        
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
        label.text = .localized(for: .inviteViewTutorial)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .primary
        
        return label
    }()
    
    let codeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "..."
        
        return label
    }()

    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(.localized(for: .inviteViewShareButton), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        
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
    
    func setCodeText(_ code: String) {
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        
        let customFd = fd.addingAttributes([
            .traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.ultraLight,
            ]
        ])
        
        let customFont = UIFont(descriptor: customFd, size: .zero)
        
        let attributedString = NSAttributedString(
            string: code,
            attributes: [
                .font: customFont,
                .foregroundColor: UIColor.primary,
                .kern: 4
            ]
        )
        
        codeLabel.attributedText = attributedString
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
        addSubview(tutorialLabel)
        addSubview(codeLabel)
        addSubview(sendButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
            make.left.right.equalToSuperview().inset(24)
        }
        
        tutorialLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.right.equalTo(titleLabel)
        }
        
        codeLabel.snp.makeConstraints { make in
            make.top.equalTo(tutorialLabel).offset(100)
            make.left.right.equalTo(tutorialLabel)
        }
        
        sendButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(24)
            make.left.right.equalTo(codeLabel)
        }
    }
}

