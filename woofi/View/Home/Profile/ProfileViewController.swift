//
//  ProfileViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 04/07/24.
//

import Combine
import UIKit

class ProfileViewController: UserViewController {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    override var viewModel: UserViewModel? {
        didSet {
            bindUser()
        }
    }
    
    // MARK: - Class Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = Session.shared.currentUser else { fatalError("User is not authenticated.") }
        setupViewModel(with: user)
        viewModel?.listenToUserUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func bindUser() {
        viewModel!.userPublisher
            .receive(on: RunLoop.main)
            .sink {
                self.userView.profileImageView.image = $0.profilePicture
                self.userView.nameTextField.text = $0.username
                self.userView.bioTextField.text = $0.bio
                self.userView.statsCollectionView.reloadData()
                print("Updated profile user.")
            }
            .store(in: &cancellables)
    }
}
