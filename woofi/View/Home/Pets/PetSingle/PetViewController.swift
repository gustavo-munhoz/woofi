//
//  PetViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import UIKit
import Combine

class PetViewController: UIViewController {
    
    var pet: Pet
    
    private var petView = PetView()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupViewModel() {
        viewModel = PetViewModel(pet: self.pet)
        petView.viewModel = viewModel
    }
}

