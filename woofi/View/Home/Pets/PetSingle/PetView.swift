//
//  PetView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import UIKit
import SnapKit

class PetView: UIView {
    
    weak var viewModel: PetViewModel?
    
    private(set) lazy var petPicture: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "dog.circle"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
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
    
    private(set) lazy var newTaskButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(systemName: "plus.circle.fill")?
            .withTintColor(.primary, renderingMode: .alwaysOriginal), for: .normal)
        
        view.setPreferredSymbolConfiguration(.init(textStyle: .largeTitle), forImageIn: .normal)
        
        return view
    }()
    
    private(set) lazy var titleStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            largeTitleLabel,
            SpacerView(axis: .horizontal),
            newTaskButton
        ])
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupConstraints()
        
        backgroundColor = .systemBackground
    }
    
//    private(set) lazy var tasksCollectionView: UICollectionView = {
//        let layout = createCompositionalLayout()
//        
//        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        return view
//    }()

    private(set) lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
        return tableView
    }()

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [
            petPicture,
            titleStack,
            tasksTableView
        ].forEach { v in
            addSubview(v)
        }
    }
    
    private func setupConstraints() {
        petPicture.snp.makeConstraints { make in
            make.top.centerX.equalTo(safeAreaLayoutGuide)
            make.width.height.equalTo(175)
        }
        
        titleStack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(petPicture.snp.bottom).offset(16)
            make.height.equalTo(42)
        }
        
//        tasksCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(titleStack.snp.bottom).offset(16)
//            make.bottom.equalTo(safeAreaLayoutGuide)
//            make.left.equalToSuperview().offset(24)
//            make.right.equalToSuperview().offset(-24)
//        }
        
        tasksTableView.snp.makeConstraints { make in
            make.top.equalTo(titleStack.snp.bottom).offset(16)
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
    }
    
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            section.interGroupSpacing = 10
            
            let sectionHeaderSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
    }
}
