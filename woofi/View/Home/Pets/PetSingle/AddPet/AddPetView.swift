//
//  AddPetView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 29/05/24.
//

import UIKit
import SnapKit

class AddPetView: UIView {

    // TODO: Localize texts

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add new pet"
        
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
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let breedTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Breed"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let ageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Age"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var createPetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create pet", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGray
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didPressCreateButton), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    var didPressCreateAction: (() -> Void)?
    
    @objc func didPressCreateButton() {
        didPressCreateAction?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubviews()
        setupConstraints()
        setupTextFieldObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(nameTextField)
        addSubview(breedTextField)
        addSubview(ageTextField)
        addSubview(createPetButton)
    }
    
    private func setupTextFieldObservers() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        breedTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let isFormValid = !(nameTextField.text?.isEmpty ?? true) &&
        !(breedTextField.text?.isEmpty ?? true) &&
        !(ageTextField.text?.isEmpty ?? true)
        
        createPetButton.isEnabled = isFormValid
        createPetButton.backgroundColor = isFormValid ? .systemBlue : .systemGray
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(30)
            make.left.right.equalToSuperview().inset(24)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(44)
        }
        
        breedTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.left.right.equalTo(nameTextField)
            make.height.equalTo(44)
        }
        
        ageTextField.snp.makeConstraints { make in
            make.top.equalTo(breedTextField.snp.bottom).offset(20)
            make.left.right.equalTo(nameTextField)
            make.height.equalTo(44)
        }
        
        createPetButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-30)
            make.left.right.equalTo(nameTextField)
            make.height.equalTo(50)
        }
    }
}
