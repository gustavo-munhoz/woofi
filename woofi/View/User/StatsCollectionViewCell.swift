//
//  StatsCollectionViewCell.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/05/24.
//

import UIKit

class StatsCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "StatsCollectionViewCell"
    
    private var number: String?
    private var text: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 8
    }
    
    private(set) lazy var statValueLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let boldFd = fd.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]
        ])
        
        view.font = UIFont(descriptor: fd, size: .zero)
        view.textColor = .primary
        view.textAlignment = .center
        
        return view
    }()
    
    private(set) lazy var statDescriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = .preferredFont(forTextStyle: .subheadline)
        view.textColor = .primary
        
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        [
            statValueLabel,
            statDescriptionLabel
        ].forEach { v in
            addSubview(v)
        }
    }
    
    func setupConstraints() {
        statValueLabel.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(44)
        }
        
        statDescriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
            make.top.equalTo(statValueLabel.snp.bottom).offset(10)
        }
    }
    
    func setup(with stat: TaskStat) {
        statValueLabel.text = "\(stat.value)"
        statDescriptionLabel.text = stat.task.description
        
        addSubviews()
        setupConstraints()
    }
}

