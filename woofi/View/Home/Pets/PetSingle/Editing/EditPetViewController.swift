//
//  EditPetViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 17/07/24.
//

import UIKit
import PhotosUI

class EditPetViewController: UIViewController {
    
    // MARK: - Properties
    
    private var editPetView = EditPetView()
    
    var viewModel: PetViewModel? {
        didSet {
            fillUI()
            editPetView.viewModel = viewModel
        }
    }
    
    // MARK: - Class Methods
    
    func setViewModel(_ vm: PetViewModel) {
        viewModel = vm
    }
    
    override func loadView() {
        view = editPetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editPetView.onPictureButtonTapped = presentImagePicker
        editPetView.onDeleteButtonTapped = alertPetDeletion
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = String.localized(for: .editPetVCNavigationItemTitle)
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            if let imageView = self.editPetView.changePictureButton.imageView {
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = imageView.frame.width / 2
                imageView.clipsToBounds = true
            }
        }
    }
    
    private func fillUI() {
        editPetView.changePictureButton.setImage(
            viewModel?.pet.picture ?? UIImage(systemName: "dog.circle"),
            for: .normal
        )
        
        editPetView.petNameTextView.text = viewModel?.pet.name
        editPetView.petBreedTextView.text = viewModel?.pet.breed
        editPetView.petAgeTextView.text = viewModel?.pet.age
    }
    
    // MARK: - Actions
    
    func alertPetDeletion() {
        guard let pet = viewModel?.pet else { return }
        
        let alert = UIAlertController(
            title: String.localized(for: .editPetVCDeleteAlertTitle(petName: pet.name)),
            message: String.localized(for: .editPetVCDeleteAlertMessage(petName: pet.name)),
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(
            title: String.localized(for: .cancel),
            style: .cancel
        )
        
        let delete = UIAlertAction(
            title: String.localized(for: .delete),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel?.deletePet(pet) {
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                    pet.publishDeleteSignal()
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        present(alert, animated: true)
    }
    
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
                        title: String.localized(for: .photosAccessDeniedTitle),
                        message: String.localized(for: .photosAccessDeniedMessage),
                        preferredStyle: .alert
                    )
                    alert.addAction(
                        UIAlertAction(
                            title: String.localized(for: .ok).uppercased(),
                            style: .default,
                            handler: nil
                        )
                    )
                    self.present(alert, animated: true, completion: nil)
                    
                @unknown default:
                    break
                }
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditPetViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self?.editPetView.updatePetImage(image)
                    self?.viewModel?.updatePetPicture(image)
                }
            }
        }
    }
}
