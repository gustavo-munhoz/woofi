//
//  GroupViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 06/05/24.
//

import UIKit
import Combine

fileprivate enum Section {
    case main
}

class GroupViewController: UIViewController, UICollectionViewDelegate {
         
    private var groupView = GroupView()
    
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<Section, User>!
    var viewModel: GroupViewModel?
    
    // MARK: - Setup methods
    
    override func loadView() {
        view = groupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        configureDataSource()
        configureCollectionView()
        setupSubscriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabvc = tabBarController as? HomeViewController {
            tabvc.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabvc = tabBarController as? HomeViewController {
            tabvc.addButton.removeTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        }
    }
    
    private func setupViewModel() {
        viewModel = GroupViewModel()
    }
    
    private func configureCollectionView() {
        groupView.setupCollectionView(
            delegate: self,
            dataSource: dataSource,
            cellClass: UserCollectionViewCell.self,
            reuseIdentifier: UserCollectionViewCell.reuseIdentifier
        )
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, User>(
            collectionView: groupView.usersCollectionView,
            cellProvider: { collectionView, indexPath, user in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: UserCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? UserCollectionViewCell
                
                cell?.setup(with: user)
                
                return cell
            }
        )
    }
    
    private func setupSubscriptions() {
        viewModel?.users
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] users in
                self?.applySnapshot(users: users)
            })
            .store(in: &cancellables)
        
        viewModel?.navigateToUserPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] user in
                self?.navigationController?.pushViewController(UserViewController(user: user), animated: true)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Runtime methods
    @objc private func didTapAddButton() {
        let alertController = UIAlertController(
            title: "Invite Options",
            message: "Please choose an option",
            preferredStyle: .actionSheet
        )
        
        let inviteAction = UIAlertAction(title: "Invite", style: .default) { _ in
            self.presentInviteViewController()
        }
        
        let joinAction = UIAlertAction(title: "Join Group", style: .default) { _ in
            self.presentJoinGroupViewController()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(inviteAction)
        alertController.addAction(joinAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func presentInviteViewController() {
        let inviteVC = InviteViewController()
        
        if let sheet = inviteVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(inviteVC, animated: true)
    }

    private func presentJoinGroupViewController() {
        let joinGroupVC = JoinGroupViewController()
        joinGroupVC.groupViewModel = viewModel
        
        if let sheet = joinGroupVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(joinGroupVC, animated: true)
    }

    
    private func applySnapshot(users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = dataSource.itemIdentifier(for: indexPath) else { return }
        
        viewModel?.navigateToUser(user)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = 1.0
        }
    }
}
