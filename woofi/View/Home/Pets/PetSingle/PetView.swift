//
//  PetView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import UIKit
import SnapKit

class PetView: UIView {
    
    weak var viewModel: PetViewModel? {
        didSet {
            petPicture.image = viewModel!.pet.picture ?? UIImage(systemName: "dog.circle")
            tasksCollectionView.reloadData()
        }
    }
    
    var onPetPictureTapped: (() -> Void)?
    
    private(set) lazy var petPicture: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(petPictureTapped))
        view.addGestureRecognizer(tapGesture)
        
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.primary.cgColor
        view.contentMode = .scaleToFill
        
        return view
    }()
    
    @objc private func petPictureTapped() {
        onPetPictureTapped?()
    }
        
    
    private(set) lazy var largeTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.text = LocalizedString.Pet.largeTitleTasks
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        let boldFd = fd.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var tasksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.headerReferenceSize = CGSizeMake(UIScreen.main.bounds.width, 60)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [
            petPicture,
            largeTitleLabel,
            tasksCollectionView
        ].forEach { v in
            addSubview(v)
        }
    }
    
    private func setupConstraints() {
        petPicture.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(175)
        }
        
        largeTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(petPicture.snp.bottom).offset(24)
            make.height.equalTo(42)
        }
        
        tasksCollectionView.snp.makeConstraints { make in
            make.top.equalTo(largeTitleLabel.snp.bottom)
            make.left.right.equalTo(largeTitleLabel)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
