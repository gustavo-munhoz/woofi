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
    
    @Published var isLoading = true
    
    /// The current list of pets in the user's group.
    @Published var pets: [Pet] = []
    
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
    
    func refreshPets() {
        addPetsListener()
    }
    
    @objc private func addPetsListener() {
        guard let currentUser = Session.shared.currentUser else {
            return
        }
        isLoading = true
        
        FirestoreService.shared.addPetsListener(groupID: currentUser.groupID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let changesDict):
                for (uid, pet) in changesDict {
                    if let index = pets.firstIndex(where: { $0.id == pet.id }) {
                        guard currentUser.id != uid else { continue }
                        
                        pets[index] = pet
                        print("Updated pet: \(pet.name)")
                    } else {
                        pets.append(pet)
                        print("Appended pet: \(pet.name)")
                    }
                }
                self.isLoading = false
                self.setupSubscriptions()

            case .failure(let error):
                print("Error fetching pets: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }

    
    func publishPetChange(_ pet: Pet) {
        updatePetPublisher.send(pet)
    }
    
    func navigateToPet(_ pet: Pet) {
        navigateToPetPublisher.send(pet)
    }
    
    func deletePet(_ pet: Pet) {
        Task {
            do {
                try await FirestoreService.shared.removePet(petId: pet.id)
                pets.removeAll(where: { pet.id == $0.id })
                
                print("Deleted pet with id: \(pet.id)")
                
            } catch {
                print("Error deleting pet: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupSubscriptions() {
        pets.forEach { pet in
            pet.deletionPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] shouldDelete in
                    if shouldDelete { self?.pets.removeAll(where: { $0.id == pet.id })}
                }
                .store(in: &pet.cancellables)
        }
        
        Session.shared.currentUser?.leaveGroupPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] didLeave in
                if didLeave {
                    self?.pets.removeAll()
                }
            }
            .store(in: &cancellables)
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
