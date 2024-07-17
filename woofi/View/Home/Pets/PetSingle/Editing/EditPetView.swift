//
//  EditPetView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 17/07/24.
//

import UIKit
import SnapKit

class EditPetView: UIView {
    
    // MARK: - Properties
    
    weak var viewModel: PetViewModel?
    
    var onPictureButtonTapped: (() -> Void)?
    var onDeleteButtonTapped: (() -> Void)?
    
    // MARK: - Subviews
    
    private(set) lazy var changePictureButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.image = UIImage(systemName: "dog.circle")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 32)
        config.imagePadding = 24
        config.baseForegroundColor = .primary
        
        config.attributedTitle = AttributedString("Change Pet Picture", attributes: AttributeContainer([
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
        let view = EditStackView(title: "Pet Picture", editView: changePictureButton)
        
        return view
    }()
    
    private(set) lazy var petNameTextView: PaddedTextView = {
        let view = PaddedTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        view.font = .preferredFont(forTextStyle: .title3)
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var petNameStackView: EditStackView = {
        EditStackView(title: "Pet name", editView: petNameTextView)
    }()
    
    private(set) lazy var petBreedTextView: PaddedTextView = {
        let view = PaddedTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        view.font = .preferredFont(forTextStyle: .title3)
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var petBreedStackView: EditStackView = {
        EditStackView(title: "Pet breed", editView: petBreedTextView)
    }()
    
    private(set) lazy var petAgeTextView: PaddedTextView = {
        let view = PaddedTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 8
        view.font = .preferredFont(forTextStyle: .title3)
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var petAgeStackView: EditStackView = {
        EditStackView(title: "Pet Age", editView: petAgeTextView)
    }()
    
    private(set) lazy var deleteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .systemRed
        config.attributedTitle = AttributedString("Delete pet", attributes: AttributeContainer([
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)
        ]))
        
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(handleDeleteButtonTap), for: .touchUpInside)
        
        return view
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
        addSubview(petNameStackView)
        addSubview(petBreedStackView)
        addSubview(petAgeStackView)
        addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        pictureStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
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
        
        petNameStackView.snp.makeConstraints { make in
            make.top.equalTo(pictureStackView.snp.bottom).offset(16)
            make.left.right.equalTo(pictureStackView)
            make.height.equalTo(80)
        }
        
        petBreedStackView.snp.makeConstraints { make in
            make.top.equalTo(petNameStackView.snp.bottom).offset(16)
            make.left.right.equalTo(petNameStackView)
            make.height.equalTo(80)
        }
        
        petAgeStackView.snp.makeConstraints { make in
            make.top.equalTo(petBreedStackView.snp.bottom).offset(16)
            make.left.right.equalTo(petNameStackView)
            make.height.equalTo(80)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - Actions
    
    @objc func handleDeleteButtonTap() {
        onDeleteButtonTapped?()
    }
    
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
    
    func updatePetImage(_ image: UIImage) {
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

extension EditPetView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel?.updatePet(
            name: petNameTextView.text,
            breed: petBreedTextView.text,
            age: petAgeTextView.text
        )
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { return false }
        
        let characterLimit = 20
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        return updatedText.count <= characterLimit
    }
}
