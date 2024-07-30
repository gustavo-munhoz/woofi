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
        label.text = .localized(for: .addPetViewTitle)
        
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
        textField.placeholder = .localized(for: .addPetViewName)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let breedTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = .localized(for: .addPetViewBreed)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let ageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = .localized(for: .addPetViewAge)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private(set) lazy var createPetButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .actionGreen
        config.attributedTitle = AttributedString(
            .localized(for: .addPetViewCreateButton),
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ])
        )
        config.buttonSize = .small
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEnabled = false
        view.configurationUpdateHandler = { button in
            var config = button.configuration
            
            switch button.state {
            case .normal:
                config?.baseBackgroundColor = .actionGreen
                button.alpha = 1
                
            case .disabled:
                config?.baseBackgroundColor = .systemGray
                button.alpha = 1
                
            case .highlighted:
                config?.baseBackgroundColor = .actionGreen
                button.alpha = 0.5
                
            default:
                break
            }
            
            button.configuration = config
        }
        
        view.addTarget(self, action: #selector(didPressCreateButton), for: .touchUpInside)
        
        return view
    }()
    
//    lazy var createPetButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle(.localized(for: .addPetViewCreateButton), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        button.backgroundColor = .systemGray
//        button.tintColor = .white
//        button.layer.cornerRadius = 12
//        button.addTarget(self, action: #selector(didPressCreateButton), for: .touchUpInside)
//        button.isEnabled = false
//        
//        return button
//    }()
    
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
        setupTapGesture()
        setupKeyboardObservers()
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
            make.bottom.equalTo(safeAreaLayoutGuide).inset(30)
            make.left.right.equalTo(nameTextField)
            make.height.equalTo(50)
        }
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
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        endEditing(true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            UIView.animate(withDuration: duration) {
                self.createPetButton.snp.updateConstraints { make in
                    make.bottom.equalTo(self.safeAreaLayoutGuide).inset(keyboardHeight + 10)
                }
                self.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            UIView.animate(withDuration: duration) {
                self.createPetButton.snp.updateConstraints { make in
                    make.bottom.equalTo(self.safeAreaLayoutGuide).inset(30)
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
