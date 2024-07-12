//
//  ProfileSetupViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/07/24.
//

import UIKit
import PhotosUI

class ProfileSetupViewController: UIViewController {
    
    private(set) var profileSetupView = ProfileSetupView()
    
    override func loadView() {
        view = profileSetupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Almost done!"
        
        profileSetupView.onPictureButtonTapped = presentImagePicker
        profileSetupView.onContinueButtonTapped = buildAndSetUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
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
    
    private func buildAndSetUser() {
        do {
            let user = try profileSetupView.userBuilder.build()
            Session.shared.currentUser = user
            
            Task {
                try await FirestoreService.shared.saveUserData(
                    userId: user.id,
                    data: [
                        FirestoreKeys.Users.uid: user.id,
                        FirestoreKeys.Users.username: user.username,
                        FirestoreKeys.Users.bio: user.bio ?? "",
                        FirestoreKeys.Users.email: user.email ?? "",
                        FirestoreKeys.Users.groupID: user.groupID,
                        FirestoreKeys.Users.profileImageUrl: user.profilePicturePath ?? "",
                    ]
                )
            }
            
            navigateToHome()
            
        } catch {
            fatalError("Error building user: \(error.localizedDescription)")
        }
    }
    
    private func navigateToHome() {
        navigationController?.pushViewController(HomeViewController(), animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProfileSetupViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    self?.profileSetupView.updateProfileImage(image)                    
                }
            }
        }
    }
}

