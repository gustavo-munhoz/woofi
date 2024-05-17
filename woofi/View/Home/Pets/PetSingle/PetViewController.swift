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

class PetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var petView = PetView()
    private var cancellables = Set<AnyCancellable>()
    
    var pet: Pet
    var viewModel: PetViewModel? {
        didSet {
            navigationItem.title = viewModel?.pet.name
            petView.tasksTableView.reloadData()
            petView.viewModel = viewModel
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
        configureTableView()
        setupSubscriptions()
    }

    private func configureTableView() {
        petView.tasksTableView.delegate = self
        petView.tasksTableView.dataSource = self
        petView.tasksTableView.register(PetTaskGroupCell.self, forCellReuseIdentifier: PetTaskGroupCell.reuseIdentifier)
        petView.tasksTableView.register(PetSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PetSectionHeaderView.reuseIdentifier)
    }
    
    private func setupViewModel() {
        let viewModel = PetViewModel(pet: pet)
        self.viewModel = viewModel
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = Section(rawValue: section)!
        switch sectionType {
        case .daily:
            return viewModel?.dailyTaskGroups.value.count ?? 0
        case .weekly:
            return viewModel?.weeklyTaskGroups.value.count ?? 0
        case .monthly:
            return viewModel?.monthlyTaskGroups.value.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetTaskGroupCell.reuseIdentifier, for: indexPath) as? PetTaskGroupCell else {
            fatalError("Could not dequeue PetTaskGroupCell")
        }
        let sectionType = Section(rawValue: indexPath.section)!
        let taskGroup = getTaskGroup(for: sectionType, at: indexPath.row)
        cell.taskGroup = taskGroup
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PetSectionHeaderView.reuseIdentifier) as? PetSectionHeaderView else {
            fatalError("Could not dequeue SectionHeaderView")
        }
        header.setup(with: Section(rawValue: section)!.title)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionType = Section(rawValue: indexPath.section)!
        let taskGroup = getTaskGroup(for: sectionType, at: indexPath.row)
        let count = taskGroup?.instances.count ?? 0
        let baseHeight = 58
        let totalHeight = CGFloat(count * baseHeight)
        return totalHeight
    }

    // TODO: Allow touch, fix spacing
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    
    // Helper function to get task group based on section and index
    private func getTaskGroup(for section: Section, at index: Int) -> PetTaskGroup? {
        guard let viewModel = self.viewModel else { return nil }
        
        switch section {
        case .daily:
            return viewModel.dailyTaskGroups.value[index]
        case .weekly:
            return viewModel.weeklyTaskGroups.value[index]
        case .monthly:
            return viewModel.monthlyTaskGroups.value[index]
        }
    }

    private func setupSubscriptions() {
        viewModel?.dailyTaskGroups
            .sink { [weak self] _ in self?.petView.tasksTableView.reloadData() }
            .store(in: &cancellables)
        
        viewModel?.weeklyTaskGroups
            .sink { [weak self] _ in self?.petView.tasksTableView.reloadData() }
            .store(in: &cancellables)
        
        viewModel?.monthlyTaskGroups
            .sink { [weak self] _ in self?.petView.tasksTableView.reloadData() }
            .store(in: &cancellables)
    }
}
