//
//  PetViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import UIKit
import Combine
import FirebaseStorage

fileprivate enum Section: Int, CaseIterable {
    case daily
    case weekly
    case monthly
    
    var title: String {
        switch self {
        case .daily:
            return .localized(for: .petVCDailyTitle)
        case .weekly:
            return .localized(for: .petVCWeeklyTitle)
        case .monthly:
            return .localized(for: .petVCMonthlyTitle)
        }
    }
}

class PetViewController: UIViewController {
    
    private var petView = PetView()
    private var cancellables = Set<AnyCancellable>()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PetTaskGroup>!
    
    var viewModel: PetViewModel
    
    unowned var petListViewModel: PetListViewModel? {
        didSet {
            petListViewModel?.$pets
                .receive(on: RunLoop.main)
                .sink { [weak self] pets in
                    guard let self = self else { return }
                    if let index = pets.firstIndex(where: { $0.id == self.viewModel.pet.id }) {
                        viewModel.pet = pets[index]
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    init(viewModel: PetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = petView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        configureDataSource()
        configureCollectionView()
        
        petView.onPetPictureTapped = { [weak self] in
            self?.presentImagePicker()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(navigateToEdit)
        )                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupViewModel() {
        petView.viewModel = viewModel
        
        navigationItem.title = viewModel.pet.name
        viewModel.$pet
            .receive(on: RunLoop.main)
            .sink { [weak self] pet in
                guard let self = self else { return }
                
                self.navigationItem.title = pet.name
                self.applySnapshot(
                    dailyTasks: pet.dailyTasks.value,
                    weeklyTasks: pet.weeklyTasks.value,
                    monthlyTasks: pet.monthlyTasks.value
                )
            }
            .store(in: &cancellables)
    }
    
    @objc private func navigateToEdit() {
        let vc = EditPetViewController()
        vc.setViewModel(viewModel)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: petView.tasksCollectionView,
            cellProvider: { collectionView, indexPath, taskGroup in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PetTaskGroupView.reuseIdentifier,
                    for: indexPath) as? PetTaskGroupView
                else { fatalError("Could not dequeue PetTaskGroupCell") }
                
                cell.setup(withTaskGroup: taskGroup, pet: self.viewModel.pet)
                return cell
            }
        )
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: UICollectionView.elementKindSectionHeader,
                for: indexPath) as? HeaderView
            
            let section = Section(rawValue: indexPath.section)
            headerView?.titleLabel.text = section?.title
            return headerView
        }
        
        applySnapshot(
            dailyTasks: viewModel.pet.dailyTasks.value,
            weeklyTasks: viewModel.pet.weeklyTasks.value,
            monthlyTasks: viewModel.pet.monthlyTasks.value
        )
    }
    
    private func configureCollectionView() {
        petView.tasksCollectionView.delegate = self
        petView.tasksCollectionView.dataSource = dataSource
        petView.tasksCollectionView.register(
            PetTaskGroupView.self,
            forCellWithReuseIdentifier: PetTaskGroupView.reuseIdentifier
        )
        petView.tasksCollectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: UICollectionView.elementKindSectionHeader
        )
    }
    
    private func applySnapshot(dailyTasks: [PetTaskGroup], weeklyTasks: [PetTaskGroup], monthlyTasks: [PetTaskGroup]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PetTaskGroup>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems(dailyTasks, toSection: .daily)
        snapshot.appendItems(weeklyTasks, toSection: .weekly)
        snapshot.appendItems(monthlyTasks, toSection: .monthly)
        
        self.dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.petView.tasksCollectionView.reloadData()
        }
    }
}

extension PetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let taskGroup = dataSource.itemIdentifier(for: indexPath) else { return CGSize.zero }
        
        let width = UIScreen.main.bounds.width - 48
        
        switch taskGroup.task {
        case .walk:
            return CGSizeMake(width, 156)
        case .feed:
            return CGSizeMake(width, 120)
        case .bath:
            return CGSizeMake(width, 120)
        case .brush:
            return CGSizeMake(width, 84)
        case .vet:
            return CGSizeMake(width, 84)
        }
    }
}

extension PetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            petView.petPicture.image = selectedImage
    
            viewModel.updatePetPicture(selectedImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
