//
//  PetListView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import UIKit
import SnapKit

class PetListView: UIView {
    var gradientLayer: CAGradientLayer!
    
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
    
    private(set) lazy var loadingStackView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: (0..<2).map { _ in UIImageView(image: UIImage(imageKey: .loadingPetCard)) }
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
    
    func setToLoadedView() {
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else { return }
            self.subviews.forEach { $0.removeFromSuperview() }
            
        } completion: { _ in
            UIView.animate(withDuration: 0.15) { [weak self] in
                guard let self = self else { return }
                
                self.addSubview(self.petsCollectionView)
                self.petsCollectionView.snp.makeConstraints { make in
                    make.top.equalTo(self.safeAreaLayoutGuide).offset(24)
                    make.bottom.equalTo(self.safeAreaLayoutGuide)
                    make.right.left.equalToSuperview().inset(24).priority(.high)
                    make.right.left.greaterThanOrEqualToSuperview().inset(24).priority(.required)
                }
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
        petsCollectionView.delegate = delegate
        petsCollectionView.dataSource = dataSource
        petsCollectionView.register(cellClass.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func startGradientAnimation() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.25).cgColor,
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.25).cgColor,
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        loadingStackView.layer.mask = gradientLayer
                
        let positionAnimation = CABasicAnimation(keyPath: "locations")
        positionAnimation.fromValue = [-0.5, 0.0, 0.5]
        positionAnimation.toValue = [0.5, 1.0, 1.5]
        positionAnimation.duration = 2
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation]
        animationGroup.duration = 2
        animationGroup.repeatCount = .infinity
        animationGroup.autoreverses = true
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animationGroup, forKey: nil)
    }
}

