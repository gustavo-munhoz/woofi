//
//  PetViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 13/05/24.
//

import Foundation
import Combine
import UIKit

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
    
    func updatePet(name: String, breed: String, age: String) {
        pet.name = name
        pet.breed = breed
        pet.age = age
        
        Task {
            do {
                try await FirestoreService.shared.updatePetData(petId: pet.id, data: [
                    FirestoreKeys.Pets.name: pet.name,
                    FirestoreKeys.Pets.breed: pet.breed,
                    FirestoreKeys.Pets.age: pet.age,
                ])
                
                print("Pet data updated successfully on Firestore.")
                pet.publishUpdates()
                changePublisher.send(pet)
            } catch {
                print("Error updating Pet on Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    func updatePetPicture(_ image: UIImage) {
        pet.picture = image
        
        Task {
            do {
                let petImageUrl = try await FirestoreService.shared.savePetImage(
                    petId: pet.id,
                    image: image
                )
                
                pet.pictureURL = petImageUrl
                pet.publishUpdates()
                changePublisher.send(pet)
                print("Pet picture and URL updated successfully: \(petImageUrl)")
                
            } catch {
                print("Error updating pet image or URL: \(error.localizedDescription)")
            }
        }
    }
}
 
