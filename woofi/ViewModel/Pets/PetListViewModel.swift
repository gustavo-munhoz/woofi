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
    
    func refreshPets() {
        addPetsListener()
    }
    
    @objc private func addPetsListener() {
        guard let currentUser = Session.shared.currentUser else {
            return
        }
        isLoading = true
        FirestoreService.shared.addPetsListener(groupID: currentUser.groupID) { [weak self] result in
            switch result {
            case .success(let changesDict):
                var updatedPets = self?.pets.value ?? []
                                                
                for (userId, pet) in changesDict {
                    if let index = updatedPets.firstIndex(where: { $0 == pet }) {
                        guard currentUser.id != userId else { continue }
                        updatedPets[index] = pet
                        print("Updated pet: \(pet.name)")
                    } else {
                        updatedPets.append(pet)
                        print("Appended pet: \(pet.name)")
                    }
                }
                self?.pets.value = updatedPets
                self?.isLoading = false
                self?.setupSubscriptions()
                
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
    
    func deletePet(_ pet: Pet) {
        Task {
            do {
                try await FirestoreService.shared.removePet(petId: pet.id)
                self.pets.value.removeAll(where: { pet == $0 })
                
                print("Deleted pet with id: \(pet.id)")
                
            } catch {
                print("Error deleting pet: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupSubscriptions() {
        pets.value.forEach { pet in
            guard pet.cancellables.isEmpty else { return }
            
            pet.updatePublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] pet in
                    guard let index = self?.pets.value.firstIndex(where: { $0 == pet }) else { return }
                    self?.pets.value[index] = pet
                }
                .store(in: &pet.cancellables)
            
            pet.deletionPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] shouldDelete in
                    if shouldDelete {
                        self?.pets.value.removeAll(where: { $0 == pet })
                    }
                }
                .store(in: &pet.cancellables)
        }
        
        Session.shared.currentUser?.leaveGroupPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] didLeave in
                if didLeave {
                    self?.pets.value.removeAll()
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
