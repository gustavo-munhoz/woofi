//
//  ProfileSetupViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/07/24.
//

import UIKit
import PhotosUI

class ProfileSetupViewController: UIViewController {
    
    private var profileSetupView = ProfileSetupView()
    
    override func loadView() {
        view = profileSetupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Almost done!"
        
        profileSetupView.onPictureButtonTapped = presentImagePicker
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
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

