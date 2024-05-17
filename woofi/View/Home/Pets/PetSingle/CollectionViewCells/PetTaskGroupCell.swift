//
//  PetTaskCollectionViewCell.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 14/05/24.
//

import UIKit

class PetTaskGroupCell: UITableViewCell {
    
    static let reuseIdentifier = "PetTaskGroupCell"
    
    weak var taskGroup: PetTaskGroup? {
        didSet {
            titleLabel.text = taskGroup?.task.description
            taskInstancesCollectionView.reloadData()
            layoutIfNeeded()
        }
    }
    
    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let fd = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFd = fd.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]
        ])
        
        view.font = UIFont(descriptor: boldFd, size: .zero)
        view.textColor = .primary
        
        return view
    }()
    
    private(set) lazy var editButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(UIImage(systemName: "ellipsis.circle.fill")?
            .withTintColor(.primary, renderingMode: .alwaysOriginal), for: .normal)
        
        view.setPreferredSymbolConfiguration(.init(textStyle: .title2), forImageIn: .normal)
        
        return view
    }()
    
    private(set) lazy var titleStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            titleLabel, 
            SpacerView(axis: .horizontal),
            editButton
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var taskInstancesCollectionView: DynamicHeightCollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 14
        layout.estimatedItemSize = CGSizeMake(UIScreen.main.bounds.width * 0.76, 22)
        layout.scrollDirection = .vertical
        
        let view = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(PetTaskInstanceCell.self, forCellWithReuseIdentifier: PetTaskInstanceCell.reuseIdentifier)
        
        
        view.delegate = self
        view.dataSource = self
        view.isScrollEnabled = false
        
        view.backgroundColor = .systemGray5
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "PetTaskGroupCell")
        addSubviews()
        setupConstraints()
        
        backgroundColor = .systemGray5
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(titleStack)
        addSubview(taskInstancesCollectionView)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        taskInstancesCollectionView.layoutIfNeeded()
        taskInstancesCollectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width , height: 1)
        return taskInstancesCollectionView.collectionViewLayout.collectionViewContentSize
    }
    
    private func setupConstraints() {
        titleStack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
        }
        
        taskInstancesCollectionView.snp.makeConstraints { make in
            make.left.right.equalTo(titleStack)
            make.top.equalTo(titleStack.snp.bottom)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}

extension PetTaskGroupCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = taskGroup?.instances.count ?? 0
        
        print("sections:", count)
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PetTaskInstanceCell.reuseIdentifier, for: indexPath) as? PetTaskInstanceCell else {
            fatalError("Could not dequeue PetTaskInstanceCell")
        }
        if let taskInstance = taskGroup?.instances[indexPath.item] {
            cell.setup(with: taskInstance)
        }
        setNeedsLayout()
        
        return cell
    }
}

class DynamicHeightCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}
