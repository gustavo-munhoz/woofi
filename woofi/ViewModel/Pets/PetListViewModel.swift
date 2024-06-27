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

    override init() {
        super.init()
        loadPets()
        observeGroupIDChanges()
    }

    @objc func loadPets() {
        guard let currentUser = Session.shared.currentUser, let groupID = currentUser.groupID else {
            pets.value = []
            return
        }

        Task {
            let result = await FirestoreService.shared.fetchPetsInSameGroup(groupID: groupID)
            switch result {
            case .success(let pets):
                self.pets.value = pets
                print("Pets fetched: \(pets.map { $0.id })")
            case .failure(let error):
                print("Error fetching pets: \(error.localizedDescription)")
                self.pets.value = []
            }
        }
    }

    func navigateToPet(_ pet: Pet) {
        navigateToPetPublisher.send(pet)
    }

    private func observeGroupIDChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadPets),
            name: .groupIDDidChange,
            object: nil
        )
    }
}
