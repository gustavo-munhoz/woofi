//
//  EditProfileView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/07/24.
//

import UIKit
import SnapKit

class EditProfileView: UIView {
    
    // MARK: - Properties
    
    weak var viewModel: UserViewModel?
    
    var onPictureButtonTapped: (() -> Void)?
    
    // MARK: - Subviews
    
    private(set) lazy var changePictureButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.image = UIImage(systemName: "person.circle")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 32)
        config.imagePadding = 24
        config.baseForegroundColor = .primary
        
        config.attributedTitle = AttributedString("Change profile picture", attributes: AttributeContainer([
            .font: UIFont.preferredFont(forTextStyle: .title3)
        ]))
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        view.addTarget(self, action: #selector(handlePictureButtonTap), for: .touchUpInside)
        view.contentHorizontalAlignment = .leading
        
        return view
    }()

    
    private(set) lazy var pictureStackView: EditStackView = {
        let view = EditStackView(title: "Profile Picture", editView: changePictureButton)
        
        return view
    }()
    
    private(set) lazy var usernameTextView: PaddedTextView = {
        let view = PaddedTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        view.font = .preferredFont(forTextStyle: .title3)
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var usernameStackView: EditStackView = {
        EditStackView(title: "Username", editView: usernameTextView)
    }()
    
    private(set) lazy var biographyTextView: PaddedTextView = {
        let view = PaddedTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        view.font = .preferredFont(forTextStyle: .title3)
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var biographyStackView: EditStackView = {
        EditStackView(title: "Biography", editView: biographyTextView)
    }()
    
    // MARK: - Class Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubviews()
        setupConstraints()
        setupTapGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(pictureStackView)
        addSubview(usernameStackView)
        addSubview(biographyStackView)
    }
    
    private func setupConstraints() {
        pictureStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(150)
        }
        
        changePictureButton.imageView?.snp.makeConstraints { make in
            make.width.height.equalTo(65)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(14)
        }
        
        changePictureButton.titleLabel?.snp.makeConstraints { make in
            make.centerY.top.bottom.equalToSuperview()
            make.left.equalTo(changePictureButton.imageView?.snp.right ?? changePictureButton).offset(24)
            make.right.equalToSuperview().inset(12)
        }
        
        usernameStackView.snp.makeConstraints { make in
            make.top.equalTo(pictureStackView.snp.bottom).offset(16)
            make.left.right.equalTo(pictureStackView)
            make.height.equalTo(90)
        }
        
        biographyStackView.snp.makeConstraints { make in
            make.top.equalTo(usernameStackView.snp.bottom).offset(16)
            make.left.right.equalTo(usernameStackView)
            make.height.equalTo(130)
        }
    }
    
    // MARK: - Actions
    
    @objc func handlePictureButtonTap() {
        onPictureButtonTapped?()
    }
    
    @objc func handleTap() {
        endEditing(true)
    }
    
    func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    func updateProfileImage(_ image: UIImage) {
        let resizedImage = image.withRenderingMode(.alwaysOriginal)
        changePictureButton.setImage(resizedImage, for: .normal)
        
        if let imageView = changePictureButton.imageView {
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
        }
    }

}

// MARK: - UITextFieldDelegate

extension EditProfileView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel?.updateUser(
            username: usernameTextView.text,
            bio: biographyTextView.text
        )
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { return false }
        
        let characterLimit = textView == usernameTextView ? 20 : 75
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        return updatedText.count <= characterLimit
    }
}
