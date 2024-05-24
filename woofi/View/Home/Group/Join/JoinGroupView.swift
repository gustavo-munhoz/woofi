//
//  JoinGroupView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 24/05/24.
//

import UIKit
import SnapKit

class JoinGroupView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Accept Group Invitation"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .primary
        return label
    }()

    let inviterLabel: UILabel = {
        let label = UILabel()
        label.text = "Invited by: "
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .primary
        return label
    }()

    let explanationLabel: UILabel = {
        let label = UILabel()
        label.text = "You are being invited to join a group. Accepting the invitation will replace your current group."
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .primary
        return label
    }()

    let acceptButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Accept"
        config.baseBackgroundColor = .systemGreen
        let button = UIButton(configuration: config)
        return button
    }()

    let declineButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Decline"
        config.baseBackgroundColor = .systemRed
        let button = UIButton(configuration: config)
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
        addSubview(inviterLabel)
        addSubview(explanationLabel)
        addSubview(acceptButton)
        addSubview(declineButton)
        
        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        inviterLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(inviterLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        acceptButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
        
        declineButton.snp.makeConstraints { make in
            make.top.equalTo(acceptButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }
}
