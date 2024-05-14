//
//  PetViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import UIKit
import Combine

fileprivate enum Section {
    case main
}

class PetListViewController: UIViewController, UICollectionViewDelegate {
    
    private var petListView = PetListView()
    
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Pet>!
    
    var viewModel: PetListViewModel?
    
    override func loadView() {
        view = petListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        configureDataSource()
        configureCollectionView()
        setupSubscriptions()
    }
    
    private func setupViewModel() {
        viewModel = PetListViewModel()
        petListView.viewModel = viewModel
    }
    
    private func configureCollectionView() {
        petListView.setupCollectionView(
            delegate: self,
            dataSource: dataSource,
            cellClass: PetCollectionViewCell.self,
            reuseIdentifier: PetCollectionViewCell.reuseIdentifier
        )
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Pet>(
            collectionView: petListView.petsCollectionView,
            cellProvider: {
                collectionView,
                indexPath,
                pet in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PetCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? PetCollectionViewCell
                
                cell?.setup(
                    with: pet,
                    isTall: self.viewModel?.pets.value.count ?? 1 <= 2
                )
                
                return cell
            }
        )
    }
    
    private func setupSubscriptions() {
        viewModel?.pets
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] pets in
                self?.applySnapshot(pets: pets)
            })
            .store(in: &cancellables)
        
        viewModel?.navigateToPetPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] pet in
                self?.navigationController?.pushViewController(PetViewController(pet: pet), animated: true)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Runtime methods
    
    private func applySnapshot(pets: [Pet]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Pet>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pets)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pet = dataSource.itemIdentifier(for: indexPath) else { return }
        
        viewModel?.navigateToPet(pet)
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
