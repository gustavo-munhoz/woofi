//
//  PetListViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import Foundation
import Combine

class PetListViewModel: NSObject {
    
    private var cancellables = Set<AnyCancellable>()

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
        setupSubscriptions()
    }

    @objc private func addPetsListener() {
        guard let currentUser = Session.shared.currentUser else {
            return
        }
        
        FirestoreService.shared.addPetsListener(groupID: currentUser.groupID) { [weak self] result in
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
    
    private func setupSubscriptions() {
        pets.value.forEach { pet in
            pet.updatePublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] pet in
                    guard let index = self?.pets.value.firstIndex(where: { $0 == pet }) else { return }
                    self?.pets.value[index] = pet
                }
                .store(in: &cancellables)
        }
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
