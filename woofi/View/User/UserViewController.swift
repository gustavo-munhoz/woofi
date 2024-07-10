//
//  UserViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit

class UserViewController: UIViewController, UICollectionViewDelegate {
    
    var user: User
    
    internal var userView = UserView()
    var viewModel: UserViewModel?
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = userView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModel()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillLayoutSubviews() {
        userView.profileImageView.layer.cornerRadius = userView.profileImageView.frame.width/2
    }
    
    internal func setupCollectionView() {
        userView.statsCollectionView.delegate = self
        userView.statsCollectionView.dataSource = self
        userView.statsCollectionView.register(
            StatsCollectionViewCell.self,
            forCellWithReuseIdentifier: StatsCollectionViewCell.reuseIdentifier
        )
    }
    
    internal func setupViewModel() {
        viewModel = UserViewModel(user: user)
        userView.viewModel = viewModel
    }
    
    internal func setupSubscriptions() {
        
    }
}

extension UserViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        user.stats.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StatsCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? StatsCollectionViewCell else {
            fatalError("Issue Dequeuing StatsCell")
        }
        
        cell.setup(with: user.stats[indexPath.item])
        
        return cell
    }
}
