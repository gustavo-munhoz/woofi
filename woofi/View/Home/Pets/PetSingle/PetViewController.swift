//
//  PetViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import UIKit
import Combine

fileprivate enum Section: Int, CaseIterable {
    case daily
    case weekly
    case monthly
    
    var title: String {
        switch self {
        case .daily:
            return LocalizedString.Pet.dailyTasksTitle
        case .weekly:
            return LocalizedString.Pet.weeklyTasksTitle
        case .monthly:
            return LocalizedString.Pet.monthlyTasksTitle
        }
    }
}

class PetViewController: UIViewController {
    
    private var petView = PetView()
    private var cancellables = Set<AnyCancellable>()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PetTaskGroup>!
    
    var pet: Pet
    var viewModel: PetViewModel? {
        didSet {
            navigationItem.title = viewModel?.pet.name
            
            pet.dailyTasks
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.applySnapshot()
                })
                .store(in: &cancellables)
            
            pet.weeklyTasks
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.applySnapshot()
                })
                .store(in: &cancellables)
            
            pet.monthlyTasks
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.applySnapshot()
                })
                .store(in: &cancellables)
        }
    }
    
    weak var listViewModel: PetListViewModel? {
        didSet {
            listViewModel?.pets
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.applySnapshot()
                })
                .store(in: &cancellables)
        }
    }
    
    init(pet: Pet) {
        self.pet = pet
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupViewModel() {
        let viewModel = PetViewModel(pet: pet)
        self.viewModel = viewModel
        petView.viewModel = viewModel
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: petView.tasksCollectionView,
            cellProvider: { collectionView, indexPath, taskGroup in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PetTaskGroupView.reuseIdentifier,
                    for: indexPath) as? PetTaskGroupView
                else { fatalError("Could not dequeue PetTaskGroupCell") }
                
                cell.setup(withTaskGroup: taskGroup, petID: self.viewModel?.pet.id)
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
        
//        applySnapshot()
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
        print("Applying snapshot: Daily \(dailyTasks.count), Weekly \(weeklyTasks.count), Monthly \(monthlyTasks.count)")
        var snapshot = NSDiffableDataSourceSnapshot<Section, PetTaskGroup>()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems(dailyTasks, toSection: .daily)
        snapshot.appendItems(weeklyTasks, toSection: .weekly)
        snapshot.appendItems(monthlyTasks, toSection: .monthly)
        
        dataSource.apply(snapshot, animatingDifferences: true)
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
