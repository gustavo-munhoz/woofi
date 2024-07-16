//
//  UserViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit
import Combine

class UserViewController: UIViewController, UICollectionViewDelegate {
    
    private var cancellables = Set<AnyCancellable>()
    internal var userView = UserView()
    var viewModel: UserViewModel?
    
    override func loadView() {
        view = userView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
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
    
    internal func setupViewModel(with user: User) {
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
        viewModel?.user.stats.count ?? 4
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StatsCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? StatsCollectionViewCell, let viewModel = viewModel else {
            fatalError("Issue Dequeuing StatsCell")
        }
        
        cell.setup(with: viewModel.user.stats[indexPath.item])
        
        return cell
    }
}
