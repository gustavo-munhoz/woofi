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
        petListView.refreshAction = { [weak self] in
            self?.refreshPets()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let tabvc = tabBarController as? HomeViewController {
            tabvc.addButton.addTarget(self, action: #selector(presentAddPetSheet), for: .touchUpInside)
        }
        
        petListView.startGradientAnimation()
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
    
    private func refreshPets() {
        viewModel?.refreshPets()
        petListView.petsCollectionView.refreshControl?.endRefreshing()
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
                    isTall: self.viewModel?.pets.count ?? 1 <= 2
                )
                
                let interaction = UIContextMenuInteraction(delegate: self)
                cell?.addInteraction(interaction)                
                
                return cell
            }
        )
    }
    
    private func setupSubscriptions() {
        viewModel?.$pets
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] pets in
                self?.applySnapshot(pets: pets)
                
                if pets.isEmpty {
                    self?.petListView.setToLoadedView(isEmpty: true)
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
        
        viewModel?.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let vm = self?.viewModel else { return }
                if !isLoading {
                    self?.petListView.setToLoadedView(isEmpty: vm.pets.isEmpty)
                }
            }
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
        snapshot.appendItems(pets, toSection: .main)
        print("Applying snapshot for \(pets.count) pets.")
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.petListView.petsCollectionView.reloadData()
        }
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
              indexPath.row < viewModel.pets.count else {
            return nil
        }
        
        let pet = viewModel.pets[indexPath.row]
        
        return UIContextMenuConfiguration(actionProvider: {
            [weak self] suggestedActions in
            let editAction = UIAction(
                title: .localized(for: .petListVCContextMenuEdit),
                image: UIImage(systemName: "square.and.pencil")
            ) { _ in
                self?.presentPetEditView(for: pet)
            }
            
            let deleteAction = UIAction(
                title: .localized(for: .petListVCContextMenuDelete),
                image: UIImage(systemName: "trash"),
                attributes: [.destructive]
            ) { _ in
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
            title: .localized(for: .petListVCDeleteAlertTitle(petName: pet.name)),
            message: .localized(for: .petListVCDeleteAlertMessage(petName: pet.name)),
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(
            title: .localized(for: .cancel),
            style: .cancel
        )
        
        let delete = UIAlertAction(
            title: .localized(for: .delete),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel?.deletePet(pet)
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        present(alert, animated: true)
    }
}
