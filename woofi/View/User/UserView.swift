//
//  UserView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit
import SnapKit
import Combine

class UserView: UIView {
    
    // MARK: - Properties
    
    weak var viewModel: UserViewModel? {
        didSet {
            setupData()
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        
        backgroundColor = .systemBackground
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    
    private(set) lazy var profileImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "person.crop.circle")!)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.tintColor = .primary
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    private(set) lazy var nameTextField: UILabel = {
        let textField = UILabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        let semiboldDescriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])
        
        textField.font = UIFont(descriptor: semiboldDescriptor, size: .zero)
        textField.textColor = .primary
        textField.textAlignment = .center
        textField.isUserInteractionEnabled = false
        
        return textField
    }()
    
    private(set) lazy var bioTextField: UILabel = {
        let textField = UILabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
       
        textField.font = .preferredFont(forTextStyle: .subheadline)
        textField.textColor = .primary.withAlphaComponent(0.6)
        textField.textAlignment = .center
        textField.isUserInteractionEnabled = false 
        
        return textField
    }()
    
    private(set) lazy var textsStackView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: [
                nameTextField,
                bioTextField,
                SpacerView(axis: .vertical)
            ]
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.axis = .vertical
        view.alignment = .leading
        
        return view
    }()
    
    private(set) lazy var statsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .primary
        label.text = LocalizedString.Tasks.title
        return label
    }()
    
    private(set) lazy var statsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.41, height: UIScreen.main.bounds.height * 0.154)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        
        return collectionView
    }()
    
    // MARK: - Setup methods
    
    func setupData() {
        if let profilePicture = viewModel?.user.profilePicture {
            profileImageView.image = profilePicture
        }
        
        nameTextField.text = viewModel?.user.username
        bioTextField.text = viewModel?.user.bio
    }
    
    func addSubviews() {
        addSubview(profileImageView)
        addSubview(textsStackView)
        addSubview(statsLabel)
        addSubview(statsCollectionView)
    }
    
    func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.left.equalToSuperview().offset(24)
            make.width.height.equalTo(100)
        }                
        
        textsStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(16)
            make.right.equalToSuperview().inset(24)
            make.height.equalTo(profileImageView)
        }
        
        statsLabel.snp.makeConstraints { make in
            make.left.equalTo(safeAreaLayoutGuide).offset(24)
            make.right.equalTo(safeAreaLayoutGuide).offset(-24)
            make.top.equalTo(profileImageView.snp.bottom).offset(24)
            make.height.equalTo(34)
        }
        
        statsCollectionView.snp.makeConstraints { make in
            make.centerX.left.right.equalTo(statsLabel)
            make.top.equalTo(statsLabel.snp.bottom).offset(16)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
        }
    }
}
