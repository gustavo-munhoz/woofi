//
//  PetViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import UIKit
import Combine

class PetViewController: UIViewController {
    
    private var petView = PetView()
    private var cancellables = Set<AnyCancellable>()
    
    var pet: Pet
    var viewModel: PetViewModel? {
        didSet {
            navigationItem.title = viewModel?.pet.name
            
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
    }

    
    private func setupViewModel() {
        let viewModel = PetViewModel(pet: pet)
        self.viewModel = viewModel
        petView.viewModel = viewModel
    }
}
