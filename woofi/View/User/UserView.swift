//
//  UserView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit

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
    
    /// Contains the user name as content.
    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        let semiboldDescriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])
        
        // Font size will not be set due to descriptor
        label.font = UIFont(descriptor: semiboldDescriptor, size: .zero)

        label.textColor = .primary
        label.textAlignment = .center
        
        return label
    }()
    
    /// Contains the user's description as content.
    private(set) lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
       
        view.font = .preferredFont(forTextStyle: .subheadline)
        view.textColor = .primary.withAlphaComponent(0.6)
        view.textAlignment = .center
        
        return view
    }()
    
    /// Separates the top items from the collection view below.
    private(set) lazy var topSectionSeparator: UIView = {
        let view = UIView()
        
        view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var statsLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = .preferredFont(forTextStyle: .title1)
        view.textColor = .primary
        view.text = LocalizedString.Tasks.title
        
        return view
    }()
    
    private(set) lazy var statsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(UIScreen.main.bounds.width * 0.41, UIScreen.main.bounds.height * 0.154)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        
        return view
    }()
    
    // MARK: - Setup methods
    
    func setupData() {
        nameLabel.text = viewModel?.user.name
        descriptionLabel.text = viewModel?.user.description
    }
    
    func addSubviews() {
        [
            nameLabel,
            descriptionLabel,
            topSectionSeparator,
            statsLabel,
            statsCollectionView
        ].forEach { view in
            addSubview(view)
        }
    }
    
    func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.centerX.top.equalTo(safeAreaLayoutGuide)
            make.width.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
        }
        
        topSectionSeparator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(1)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
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
}



