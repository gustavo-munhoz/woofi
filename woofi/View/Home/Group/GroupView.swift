//
//  GroupView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 06/05/24.
//

import UIKit
import SnapKit

class GroupView: UIView {
    
    var refreshAction: (() -> Void)?
    
    private(set) lazy var usersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSizeMake(UIScreen.main.bounds.width - 48, 82)
        layout.minimumInteritemSpacing = 16
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.alwaysBounceVertical = true
        view.backgroundColor = .systemBackground
        view.refreshControl = refreshControl
        
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    private(set) lazy var loadingStackView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: Array(
                repeating: UIImageView(image: UIImage(imageKey: .loadingUserCard)),
                count: 5
            )
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .fill
        view.distribution = .fillEqually
        
        
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
    
    func setToLoadedView() {
        UIView.animate(withDuration: 0.35) { [weak self] in
            guard let self = self else { return }
            self.subviews.forEach { $0.removeFromSuperview() }
            
            self.addSubview(self.usersCollectionView)
            self.usersCollectionView.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(24)
                make.right.equalToSuperview().offset(-24)
                make.left.equalToSuperview().offset(24)
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-24)
            }
        }
    }
    
    private func addSubviews() {
        addSubview(loadingStackView)
    }
    
    private func setupConstraints() {
        loadingStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.left.right.equalToSuperview().inset(24)
        }
    }
    
    func setupCollectionView(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        cellClass: AnyClass,
        reuseIdentifier: String
    ) {
        usersCollectionView.delegate = delegate
        usersCollectionView.dataSource = dataSource
        usersCollectionView.register(cellClass.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    @objc func handleRefresh() {
        refreshAction?()
    }
}

