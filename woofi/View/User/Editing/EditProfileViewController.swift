//
//  EditProfileViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 09/07/24.
//

import UIKit
import PhotosUI

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
        
        editProfileView.onPictureButtonTapped = presentImagePicker
    }
    
    private func fillUI() {
        editProfileView.changePictureButton.setImage(
            viewModel?.user.profilePicture ?? UIImage(systemName: "person.circle"),
            for: .normal
        )
        
        editProfileView.usernameTextView.text = viewModel?.user.username
        editProfileView.biographyTextView.text = viewModel?.user.bio
    }
    
    // MARK: - Actions
    
    func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    // TODO: Fix image size.
                    self?.editProfileView.updateProfileImage(image)
                    self?.viewModel?.user.profilePicture = image
                    
                    Task {
                        do {
                            if let userID = self?.viewModel?.user.id {
                                let profileImageUrl = try await FirestoreService.shared.saveProfileImage(
                                    userID: userID,
                                    image: image
                                )
                                print("User profile image URL updated successfully: \(profileImageUrl)")
                            }
                        } catch (let error) {
                            print("Error updating image URL: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
