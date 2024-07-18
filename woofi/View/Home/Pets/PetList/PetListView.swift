//
//  PetListView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import UIKit
import SnapKit

class PetListView: UIView {
    
    weak var viewModel: PetListViewModel? {
        didSet {
            updateCollectionViewLayout()
        }
    }
    
    var refreshAction: (() -> Void)?
    
    private(set) lazy var petsCollectionView: UICollectionView = {
        let layout = createCollectionViewLayout(for: viewModel?.pets.value.count ?? 1)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.refreshControl = refreshControl
        view.clipsToBounds = false
        
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleRefresh() {
        refreshAction?()
    }
    
    private func createCollectionViewLayout(for petCount: Int) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
    
        layout.itemSize = CGSizeMake(
            UIScreen.main.bounds.width - 48,
            petCount < 3 ? 438 : 175
        )
        
        return layout
    }
    
    private func updateCollectionViewLayout() {
        guard let petCount = viewModel?.pets.value.count else { return }
        
        let newLayout = createCollectionViewLayout(for: petCount)
        self.petsCollectionView.setCollectionViewLayout(newLayout, animated: true)
    }
    
    private func addSubviews() {
        addSubview(petsCollectionView)
    }
    
    private func setupConstraints() {
        petsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(24)
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.right.left.equalToSuperview().inset(24).priority(.high)
            make.right.left.greaterThanOrEqualToSuperview().inset(24).priority(.required)
        }
    }
    
    func setupCollectionView(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        cellClass: AnyClass,
        reuseIdentifier: String
    ) {
        petsCollectionView.delegate = delegate
        petsCollectionView.dataSource = dataSource
        petsCollectionView.register(cellClass.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

