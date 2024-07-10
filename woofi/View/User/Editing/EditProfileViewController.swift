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
    
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            if let imageView = self.editProfileView.changePictureButton.imageView {
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = imageView.frame.width / 2
                imageView.clipsToBounds = true
            }
        }
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
    
    private func presentImagePicker() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    var config = PHPickerConfiguration()
                    config.filter = .images
                    config.selectionLimit = 1
                    
                    let picker = PHPickerViewController(configuration: config)
                    picker.delegate = self
                    self.present(picker, animated: true, completion: nil)
                    
                case .denied, .restricted, .notDetermined:
                    let alert = UIAlertController(
                        title: "Acesso às Fotos Negado",
                        message: "Por favor, permita o acesso às suas fotos nas configurações do dispositivo.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                @unknown default:
                    break
                }
            }
        }
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
                    self?.editProfileView.updateProfileImage(image)
                    self?.viewModel?.updateUserProfileImage(image)
                }
            }
        }
    }
}
