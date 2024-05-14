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
    }
    
    func loadPets() {
        let pet1 = Pet(id: "1", name: "Skippy", breed: "Schipperke", age: "1 year")
        let pet2 = Pet(id: "2", name: "Daftonerson Scrobblers da Silva", breed: "Schipperke", age: "1 year")
        let pet3 = Pet(id: "3", name: "Cachorra Burra", breed: "Gato", age: "1 year")
        
        pets.value = [pet1, pet2, pet3]
    }
    
    func navigateToPet(_ pet: Pet) {
        navigateToPetPublisher.send(pet)
    }
}
