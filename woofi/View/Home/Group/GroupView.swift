//
//  GroupView.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 06/05/24.
//

import UIKit
import SnapKit
import Lottie

class GroupView: UIView {
    
    var isEmpty = false
    var gradientLayer: CAGradientLayer!
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
    
    // MARK: - Loading group
    private(set) lazy var loadingStackView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: (0..<5).map { _ in UIImageView(image: UIImage(imageKey: .loadingUserCard)) }
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
    
    // MARK: - Empty group
    private(set) lazy var emptyGroupLottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "error-group")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        
        return view
    }()
    
    private(set) lazy var emptyGroupLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.text = .localized(for: .groupViewEmptyText)
        view.textColor = .primary.withAlphaComponent(0.6)
        view.textAlignment = .center
        view.numberOfLines = -1
        view.lineBreakMode = .byWordWrapping
        view.font = .preferredFont(forTextStyle: .title3)
        
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLottieAnimationAndText() {
        addSubview(emptyGroupLottieView)
        addSubview(emptyGroupLabel)
                
        emptyGroupLottieView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(emptyGroupLottieView.snp.width)
        }
        
        emptyGroupLabel.snp.makeConstraints { make in
            make.centerX.equalTo(emptyGroupLottieView)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.top.equalTo(emptyGroupLottieView.snp.bottom)
        }
        
        emptyGroupLottieView.play()
    }
    
    func setToLoadedView(isEmpty: Bool = false) {
        self.isEmpty = isEmpty
        
        UIView.animate(withDuration: 0.35) { [weak self] in
            guard let self = self else { return }
            self.subviews.forEach { $0.removeFromSuperview() }
            
        } completion: { _ in
            if isEmpty {
                self.setupLottieAnimationAndText()
                
            } else {
                self.setupCollectionViewAndConstraints()
            }
        }
    }
    
    private func setupCollectionViewAndConstraints() {
        addSubview(usersCollectionView)
        usersCollectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(24)
            make.right.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-24)
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

