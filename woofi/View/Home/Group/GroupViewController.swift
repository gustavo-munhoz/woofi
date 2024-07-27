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

class GroupViewController: UIViewController {
         
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
        setupSubscriptions()
        configureDataSource()
        configureCollectionView()
        groupView.refreshAction = refreshGroup
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let tabvc = tabBarController as? HomeViewController {
            tabvc.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        }
        
        groupView.startGradientAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabvc = tabBarController as? HomeViewController {
            tabvc.addButton.removeTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for cell in groupView.usersCollectionView.visibleCells {
            if let userCell = cell as? UserCollectionViewCell {
                userCell.profilePicture.layer.cornerRadius = 27
            }
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
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] users in
                guard !users.isEmpty else { return }
                
                self?.applySnapshot(users: users.sortedByUsername())
            })
            .store(in: &cancellables)
        
        viewModel?.navigateToUserPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] user in
                let vc = UserViewController()
                vc.setupViewModel(with: user)
                
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .store(in: &cancellables)
        
        viewModel?.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.groupView.setToLoadedView()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Runtime methods
    private func refreshGroup() {
        Task {
            await viewModel?.refreshGroup()
        }
        
        self.groupView.usersCollectionView.refreshControl?.endRefreshing()
    }

    
    @objc private func didTapAddButton() {
        let alertController = UIAlertController(
            title: .localized(for: .groupVCAlertTitle),
            message: .localized(for: .groupVCAlertMessage),
            preferredStyle: .actionSheet
        )
        
        let inviteAction = UIAlertAction(
            title: .localized(for: .groupVCInviteActionTitle),
            style: .default
        ) { _ in
            self.presentInviteViewController()
        }
        
        let joinAction = UIAlertAction(
            title: .localized(for: .groupVCJoinActionTitle),
            style: .default
        ) { _ in
            self.presentJoinGroupViewController()
        }
        
        let cancelAction = UIAlertAction(
            title: .localized(for: .cancel),
            style: .cancel,
            handler: nil
        )
        
        alertController.addAction(inviteAction)
        alertController.addAction(joinAction)
        
        if let vm = viewModel, !vm.users.value.isEmpty {
            let leaveAction = UIAlertAction(
                title: .localized(for: .groupVCLeaveActionTitle),
                style: .destructive
            ) { _ in
                self.showLeaveWarning()
            }
            alertController.addAction(leaveAction)
        }
        
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

    private func showLeaveWarning() {
        let alertController = UIAlertController(
            title: .localized(for: .groupVCLeaveWarningTitle),
            message: .localized(for: .groupVCLeaveWarningMessage),
            preferredStyle: .alert
        )
        
        let leaveAction = UIAlertAction(
            title: .localized(for: .groupVCLeaveWarningConfirm),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel?.leaveGroup()
        }
        
        let cancelAction = UIAlertAction(
            title: .localized(for: .cancel),
            style: .cancel
        )
        
        alertController.addAction(leaveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func applySnapshot(users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users)
        print("Applying snapshot with \(users.count) users.")
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.groupView.usersCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension GroupViewController: UICollectionViewDelegate {
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
