//
//  PetViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import Foundation
import Combine

class PetViewModel {
    var pet: Pet {
        didSet {
            changePublisher.send(pet)
        }
    }
    
    var changePublisher = PassthroughSubject<Pet, Never>()
    
    init(pet: Pet) {
        self.pet = pet
    }
}
 
