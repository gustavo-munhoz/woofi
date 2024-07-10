//
//  UserCollectionViewCell.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit


class UserCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "UserCell"
    
    private var image: UIImage?
    private var title: String?
    private var subtitle: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 13
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var profilePicture: UIImageView = {
        let view = UIImageView(
            image: image ?? UIImage(
                systemName: "person.crop.circle"
            )?.withTintColor(.primary, renderingMode: .alwaysOriginal)
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = title
        view.textColor = .primary
        view.font = .preferredFont(forTextStyle: .headline)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.text = subtitle
        view.textColor = .primary.withAlphaComponent(0.6)
        view.font = .preferredFont(forTextStyle: .subheadline)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()    
    
    func setup(with user: User) {
        self.image = user.profilePicture
        self.title = user.username
        self.subtitle = user.bio
        
        addSubviews()
        setupConstraints()
    }
    
    func addSubviews() {
            addSubview(profilePicture)
            addSubview(titleLabel)
            addSubview(descriptionLabel)
    }
    
    func setupConstraints() {
        profilePicture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(18)
            make.width.height.equalTo(54)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePicture.snp.top).offset(4)
            make.left.equalTo(profilePicture.snp.right).offset(16)
            make.right.equalToSuperview().offset(18)
            make.height.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.height.equalTo(titleLabel)
        }
    }
}
