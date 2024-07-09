//
//  EditProfileViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/07/24.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private var editProfileView = EditProfileView()
    
    weak var viewModel: UserViewModel? {
        didSet {
            fillUI()
            editProfileView.viewModel = viewModel
        }
    }
    
    // MARK: - Class Methods
    
    func setViewModel(_ vm: UserViewModel) {
        viewModel = vm
    }
    
    override func loadView() {
        view = editProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    private func fillUI() {
        editProfileView.changePictureButton.setImage(
            viewModel?.user.profilePicture ?? UIImage(systemName: "person.circle"),
            for: .normal
        )
        
        editProfileView.usernameTextView.text = viewModel?.user.username
        
        editProfileView.biographyTextView.text = viewModel?.user.bio
    }
}

