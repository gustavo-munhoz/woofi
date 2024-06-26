//
//  AddPetViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 29/05/24.
//

import UIKit

class AddPetViewController: UIViewController {
    
    private var addPetView = AddPetView()
    
    override func loadView() {
        view = addPetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPetView.didPressCreateAction = savePet
    }
    
    private func savePet() {
        guard let name = addPetView.nameTextField.text, !name.isEmpty,
              let breed = addPetView.breedTextField.text, !breed.isEmpty,
              let age = addPetView.ageTextField.text, !age.isEmpty else {
            print("Please fill in all fields")
            
            return
        }
        
        let petID = UUID().uuidString
        guard let currentUser = Session.shared.currentUser, let groupID = currentUser.groupID else {
            print("Current user or group ID not found")
            return
        }
        
        let pet = Pet(id: petID, name: name, breed: breed, age: age, groupID: groupID)
        
        let petData: [String: Any] = [
            "id": pet.id,
            "name": pet.name,
            "breed": pet.breed,
            "age": pet.age,
            "groupID": pet.groupID ?? ""
        ]
        
        FirestoreService.shared.savePetData(petId: petID, data: petData) { error in
            if let error = error {
                print("Failed to save pet: \(error.localizedDescription)")
                
            } else {
                print("Successfully saved pet")
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

