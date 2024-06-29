//
//  PetCollectionViewCell.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import UIKit

fileprivate enum CellType {
    case tall
    case wide
}

class PetCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PetCollectionViewCell"
    
    private var type: CellType = .tall
    
    private var image: UIImage? {
        didSet {
            petImageView.image = image
        }
    }
    private var name: String?
    private var breed: String?
    private var age: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 15
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var petImageView: UIImageView = {
        let view = UIImageView(
            image: image ?? UIImage(
                systemName: "dog.fill"
            )?.withTintColor(.primary, renderingMode: .alwaysOriginal)
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill        
        view.clipsToBounds = true
        
        return view
    }()
    
    private(set) lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = name
        view.textColor = .primary
        view.adjustsFontSizeToFitWidth = true
        view.numberOfLines = 2
        view.lineBreakMode = .byTruncatingTail
        view.minimumScaleFactor = 0.5
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        
        let semiboldfd = fd.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])
        
        view.font = UIFont(descriptor: semiboldfd, size: .zero)
        
        return view
    }()
    
    private(set) lazy var breedLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = type == .tall ? "\(breed ?? "-")," : breed
        view.textColor = .primary.withAlphaComponent(0.6)
        
        view.adjustsFontSizeToFitWidth = true
        view.numberOfLines = 2
        view.lineBreakMode = .byTruncatingTail
        view.minimumScaleFactor = 0.5
        
        view.font = .preferredFont(forTextStyle: .title2)
        
        return view
    }()
    
    private(set) lazy var ageLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = age
        view.textColor = .primary.withAlphaComponent(0.6)
        
        view.font = .preferredFont(forTextStyle: .title2)
        
        return view
    }()
    
    private(set) lazy var stackView: UIStackView = {
        let spacer = UIView()
        
        let ct: NSLayoutConstraint.Axis = type == .tall ? .horizontal : .vertical
        
        spacer.isUserInteractionEnabled = false
        spacer.setContentHuggingPriority(.fittingSizeLevel, for: ct)
        spacer.setContentCompressionResistancePriority(.fittingSizeLevel, for: ct)
        
        let subviews = type == .tall ? [breedLabel, ageLabel, spacer] : [nameLabel, breedLabel, ageLabel, spacer]
        
        let view = UIStackView(arrangedSubviews: subviews)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = type == .tall ? .horizontal : .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = type == .tall ? 6 : 10
        
        return view
    }()
    
    func setup(with pet: Pet, isTall: Bool = true) {
        self.image = pet.picture
        self.name = pet.name
        self.breed = pet.breed
        self.age = pet.age
        
        if !isTall { self.type = .wide }
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        addSubview(petImageView)
        
        if type == .tall { addSubview(nameLabel) }
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        if type == .tall {
            setupConstraintsForTallCell()
        }
        
        else {
            setupConstraintsForWideCell()
        }
    }
    
    private func setupConstraintsForTallCell() {
        petImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.75)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(petImageView.snp.bottom).offset(16)
            make.height.equalTo(34)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func setupConstraintsForWideCell() {
        petImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.45)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalTo(petImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}

