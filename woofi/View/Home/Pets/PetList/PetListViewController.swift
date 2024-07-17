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
    
    var currentPet: Pet?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let tabvc = tabBarController as? HomeViewController {
            tabvc.addButton.addTarget(self, action: #selector(presentAddPetSheet), for: .touchUpInside)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabvc = tabBarController as? HomeViewController {
            tabvc.addButton.removeTarget(self, action: #selector(presentAddPetSheet), for: .touchUpInside)
        }
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
                
                let interaction = UIContextMenuInteraction(delegate: self)
                cell?.addInteraction(interaction)                
                
                return cell
            }
        )
    }
    
    private func setupSubscriptions() {
        viewModel?.pets
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] pets in
                self?.applySnapshot(pets: pets)
                
                guard let currentPet = self?.currentPet else { return }
                
                for p in pets {
                    if p == currentPet {
                        self?.currentPet = p
                        self?.viewModel?.publishPetChange(p)
                    }
                }
            })
            .store(in: &cancellables)
        
        viewModel?.navigateToPetPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] pet in
                self?.currentPet = pet
                let vm = PetViewModel(pet: pet)
                let vc = PetViewController(viewModel: vm)
                vc.petListViewModel = self?.viewModel
                
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Runtime methods
    @objc private func presentAddPetSheet() {
        let vc = AddPetViewController()
        vc.petListViewModel = self.viewModel
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(vc, animated: true)
    }
    
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

extension PetListViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = petListView.petsCollectionView.indexPathForItem(at: location),
              let viewModel = viewModel,
              indexPath.row < viewModel.pets.value.count else {
            return nil
        }
        
        let pet = viewModel.pets.value[indexPath.row]
        
        return UIContextMenuConfiguration(actionProvider: { [weak self] suggestedActions in
            let editAction = UIAction(title: "Edit pet", image: UIImage(systemName: "square.and.pencil")) { _ in
                self?.presentPetEditView(for: pet)
            }
            
            let deleteAction = UIAction(title: "Delete pet", image: UIImage(systemName: "trash"), attributes: [.destructive]) { _ in
                self?.alertPetDeletion(for: pet)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        })
    }
    
    func presentPetEditView(for pet: Pet) {
        let vc = EditPetViewController()
        vc.setViewModel(PetViewModel(pet: pet))
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func alertPetDeletion(for pet: Pet) {
        let alert = UIAlertController(
            title: "Delete \(pet.name)",
            message: "Are you sure you want to delete \(pet.name)? This will delete \(pet.name) for everyone in your group.",
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel?.deletePet(pet)
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        present(alert, animated: true)
    }
}
