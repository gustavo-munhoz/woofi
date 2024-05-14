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
    
    private(set) lazy var petsCollectionView: UICollectionView = {
        let layout = createCollectionViewLayout(for: viewModel?.pets.value.count ?? 1)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        
        return view
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
            make.top.left.equalTo(safeAreaLayoutGuide).offset(24)
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.right.equalToSuperview().offset(-24)
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

