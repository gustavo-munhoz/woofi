//
//  PetListViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import Foundation
import Combine

class PetListViewModel: NSObject {

    /// The current list of pets in the user's group.
    var pets = CurrentValueSubject<[Pet], Never>.init([])
    
    /// The publisher to signal controllers to navigate.
    var navigateToPetPublisher = PassthroughSubject<Pet, Never>()
    
    /// Used to update pet after listener updates.
    var updatePetPublisher = PassthroughSubject<Pet, Never>()

    override init() {
        super.init()
        addPetsListener()
        observeGroupIDChanges()
    }

    @objc private func addPetsListener() {
        guard let currentUser = Session.shared.currentUser, let groupID = currentUser.groupID else {
            return
        }
        
        FirestoreService.shared.addPetsListener(groupID: groupID) { [weak self] result in
            switch result {
                case .success(let pets):
                    self?.pets.value = pets
                case .failure(let error):
                    print("Error fetching pets: \(error.localizedDescription)")
            }
        }
    }

    func publishPetChange(_ pet: Pet) {
        updatePetPublisher.send(pet)
    }
    
    func navigateToPet(_ pet: Pet) {
        navigateToPetPublisher.send(pet)
    }

    private func observeGroupIDChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addPetsListener),
            name: .groupIDDidChange,
            object: nil
        )
    }
}
