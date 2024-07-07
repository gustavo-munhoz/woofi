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
    
    var isEditable: Bool = false
    
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
        setupTapGestureRecognizer()
        
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIsEditable(_ value: Bool) {
        isEditable = value
        nameTextField.isUserInteractionEnabled = isEditable
        descriptionTextField.isUserInteractionEnabled = isEditable
    }
    
    // MARK: - Subviews
    
    private(set) lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        let semiboldDescriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])
        
        textField.font = UIFont(descriptor: semiboldDescriptor, size: .zero)
        textField.textColor = .primary
        textField.textAlignment = .center
        textField.isUserInteractionEnabled = false
        textField.delegate = self
        
        return textField
    }()
    
    private(set) lazy var descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
       
        textField.font = .preferredFont(forTextStyle: .subheadline)
        textField.textColor = .primary.withAlphaComponent(0.6)
        textField.textAlignment = .center
        textField.isUserInteractionEnabled = false
        textField.delegate = self
        
        return textField
    }()
    
    private(set) lazy var topSectionSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
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
        nameTextField.text = viewModel?.user.username
        descriptionTextField.text = viewModel?.user.bio
    }
    
    func addSubviews() {
        
        addSubview(nameTextField)
        addSubview(descriptionTextField)
        addSubview(topSectionSeparator)
        addSubview(statsLabel)
        addSubview(statsCollectionView)
    }
    
    func setupConstraints() {
        nameTextField.snp.makeConstraints { make in
            make.centerX.top.equalTo(safeAreaLayoutGuide)
            make.width.equalToSuperview()
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.centerX.width.equalTo(nameTextField)
            make.top.equalTo(nameTextField.snp.bottom).offset(12)
        }
        
        topSectionSeparator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(1)
            make.top.equalTo(descriptionTextField.snp.bottom).offset(12)
        }
        
        statsLabel.snp.makeConstraints { make in
            make.left.equalTo(safeAreaLayoutGuide).offset(24)
            make.right.equalTo(safeAreaLayoutGuide).offset(-24)
            make.top.equalTo(topSectionSeparator.snp.bottom).offset(24)
            make.height.equalTo(34)
        }
        
        statsCollectionView.snp.makeConstraints { make in
            make.centerX.left.right.equalTo(statsLabel)
            make.top.equalTo(statsLabel.snp.bottom).offset(16)
            make.height.equalToSuperview().dividedBy(3.13)
        }
    }
    
    // MARK: - Actions
    
    func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        endEditing(true)
    }
}

extension UserView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let viewModel = viewModel else { return }
        viewModel.updateUser(name: nameTextField.text, bio: descriptionTextField.text)
    }
}
