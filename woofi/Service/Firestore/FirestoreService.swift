//
//  FirestoreService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Foundation
import FirebaseFirestore
import os

/// Shared singleton to handle Firestore logic, conforming to FirestoreServiceProtocol.
class FirestoreService: FirestoreServiceProtocol {
    
    /// Instance for global access
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FirestoreService")
    private var petListeners: [ListenerRegistration] = []
    
    /// Private constructor to enforce singleton usage
    private init() {}
    
    /// Fetches user data from Firestore
    func fetchUserData(userId: String) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            db.collection(FirestoreKeys.Users.collectionTitle).document(userId).getDocument { (document, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let document = document, document.exists, let data = document.data() {
                    continuation.resume(returning: data)
                } else {
                    let error = NSError(domain: "FirestoreService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data found"])
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Fetches all users related to the same group as the current user
    func fetchUsersInSameGroup(groupID: String) async -> Result<[User], Error> {
        do {
            print("Fetching users for group id: \(groupID)")
            
            let querySnapshot = try await db.collection(FirestoreKeys.Users.collectionTitle)
                .whereField(FirestoreKeys.Users.groupID, isEqualTo: groupID)
                .getDocuments()
            
            var users = [User]()
            for document in querySnapshot.documents {
                let data = document.data()
                if let id = data[FirestoreKeys.Users.uid] as? String,
                   id != Session.shared.currentUser?.id,
                   let name = data[FirestoreKeys.Users.username] as? String,
                   //                   let bio = data[FirestoreKeys.Users.bio] as? String,
                   let groupID = data[FirestoreKeys.Users.groupID] as? String {
                    //                    let user = User(id: id, username: name, bio: bio, groupID: groupID)
                    let user = User(id: id, username: name, groupID: groupID)
                    users.append(user)
                }
            }
            return .success(users)
            
        } catch {
            return .failure(error)
        }
    }
    
    /// Saves user data to Firestore with a server-side timestamp
    func saveUserData(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        var userData = data
        userData[FirestoreKeys.Users.createdAt] = FieldValue.serverTimestamp()
        
        db.collection(FirestoreKeys.Users.collectionTitle).document(userId).setData(userData, completion: completion)
    }
    
    /// Updates user data in Firestore
    func updateUserData(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(FirestoreKeys.Users.collectionTitle).document(userId).updateData(data, completion: completion)
    }
    
    /// Removes a user from Firestore
    func removeUser(userId: String, completion: @escaping (Error?) -> Void) {
        db.collection(FirestoreKeys.Users.collectionTitle).document(userId).delete(completion: completion)
    }
    
    /// Fetches all pets related to the group
    func fetchPetsInSameGroup(groupID: String) async -> Result<[Pet], Error> {
        do {
            logger.debug("Fetching pets for group id: \(groupID)")
            
            let querySnapshot = try await db.collection(FirestoreKeys.Pets.collectionTitle)
                .whereField(FirestoreKeys.Pets.groupID, isEqualTo: groupID)
                .getDocuments()
            
            var pets = [Pet]()
            for document in querySnapshot.documents {
                var data = document.data()
                
                // Remove the createdAt field if it exists
                data.removeValue(forKey: "createdAt")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let pet = try JSONDecoder().decode(Pet.self, from: jsonData)
                    pets.append(pet)
                } catch {
                    logger.error("Error decoding pet data: \(error.localizedDescription)")
                    logger.error("Pet data: \(data)")
                    return .failure(error)
                }
            }
            return .success(pets)
            
        } catch {
            logger.error("Error fetching pets for group id \(groupID): \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    /// Saves pet data to firestore with a server-side timestamp.
    func savePetData(petId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        logger.log("Saving pet data for id: \(petId)")
        
        var petData = data
        petData[FirestoreKeys.Pets.createdAt] = FieldValue.serverTimestamp()
        
        db.collection(FirestoreKeys.Pets.collectionTitle).document(petId).setData(petData, completion: completion)
    }
    
    func savePet(_ pet: Pet, completion: @escaping (Error?) -> Void) {
        do {
            let jsonData = try JSONEncoder().encode(pet)
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                savePetData(petId: pet.id, data: jsonObject, completion: completion)
            }
        } catch {
            completion(error)
        }
    }
    
    /// Updates pet data in Firestore
    func updatePetData(petId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(FirestoreKeys.Pets.collectionTitle).document(petId).updateData(data, completion: completion)
    }
    
    /// Removes a pet from Firestore
    func removePet(petId: String, completion: @escaping (Error?) -> Void) {
        db.collection(FirestoreKeys.Pets.collectionTitle).document(petId).delete(completion: completion)
    }
    
    func updateTaskInstance(petID: String, frequency: TaskFrequency, taskGroupID: UUID, taskInstance: PetTaskInstance, completion: @escaping (Error?) -> Void) {
        let petRef = db.collection(FirestoreKeys.Pets.collectionTitle).document(petID)
        
        let taskGroupField: String
        switch frequency {
        case .daily:
            taskGroupField = "dailyTasks"
        case .weekly:
            taskGroupField = "weeklyTasks"
        case .monthly:
            taskGroupField = "monthlyTasks"
        }
        
        petRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                completion(error ?? NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pet not found"]))
                return
            }
            
            var petData = document.data() ?? [:]
            
            var taskGroups = petData[taskGroupField] as? [[String: Any]] ?? []
            
            if let taskGroupIndex = taskGroups.firstIndex(where: { ($0["id"] as? String) == taskGroupID.uuidString }) {
                var taskGroup = taskGroups[taskGroupIndex]
                
                var instances = taskGroup["instances"] as? [[String: Any]] ?? []
                
                if let taskInstanceIndex = instances.firstIndex(where: { ($0["id"] as? String) == taskInstance.id.uuidString }) {
                    do {
                        let jsonData = try JSONEncoder().encode(taskInstance)
                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            instances[taskInstanceIndex] = jsonObject
                        }
                    } catch {
                        completion(error)
                        return
                    }
                } else {
                    do {
                        let jsonData = try JSONEncoder().encode(taskInstance)
                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            instances.append(jsonObject)
                        }
                    } catch {
                        completion(error)
                        return
                    }
                }
                
                taskGroup["instances"] = instances
                taskGroups[taskGroupIndex] = taskGroup
            } else {
                var newTaskGroup: [String: Any] = ["id": taskGroupID.uuidString, "frequency": frequency]
                do {
                    let jsonData = try JSONEncoder().encode(taskInstance)
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        newTaskGroup["instances"] = [jsonObject]
                    }
                } catch {
                    completion(error)
                    return
                }
                taskGroups.append(newTaskGroup)
            }
            
            petData[taskGroupField] = taskGroups
            petRef.setData(petData, merge: true) { error in
                completion(error)
            }
        }
    }
    
    func addPetsListener(groupID: String, onUpdate: @escaping (Result<[Pet], Error>) -> Void) {
        let petsRef = db.collection(FirestoreKeys.Pets.collectionTitle).whereField("groupID", isEqualTo: groupID)
        
        let listener = petsRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                onUpdate(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                onUpdate(.success([]))
                return
            }
            
            var pets: [Pet] = []
            for document in documents {
                var data = document.data()
                
                // Remove the createdAt field if it exists
                data.removeValue(forKey: "createdAt")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let pet = try JSONDecoder().decode(Pet.self, from: jsonData)
                    
                    // Fetch the picture if it exists
                    if let pictureURLString = pet.pictureURL,
                       let pictureURL = URL(string: pictureURLString) {
                        self.fetchImage(from: pictureURL) { result in
                            switch result {
                            case .success(let image):
                                pet.picture = image
                            case .failure(let error):
                                print("Failed to fetch image: \(error)")
                            }
                        }
                    }
                    
                    pets.append(pet)
                } catch {
                    onUpdate(.failure(error))
                    return
                }
            }
            
            onUpdate(.success(pets))
        }
        
        petListeners.append(listener)
    }
    
    private func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "ImageErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"])))
                return
            }
            
            completion(.success(image))
        }.resume()
    }
    
    func removeAllListeners() {
        for listener in petListeners {
            listener.remove()
        }
        petListeners.removeAll()
    }
}

extension FirestoreService {
    func generateSimplifiedID(from groupID: String) -> String {
        let hashData = groupID.sha256()
        let base36String = hashData.base36EncodedString()
        
        let simplifiedID = String(base36String.prefix(6))
        return simplifiedID
    }
    
    func generateInviteCode(forGroupID groupID: String) async -> Result<String, Error> {
        let simplifiedID = generateSimplifiedID(from: groupID)
        let inviteData: [String: Any] = ["groupID": groupID]
        
        do {
            try await db.collection("invites").document(simplifiedID).setData(inviteData)
            return .success(simplifiedID)
        } catch {
            return .failure(error)
        }
    }
    
    func fetchGroupID(forInviteCode inviteCode: String) async -> Result<String, Error> {
        do {
            let document = try await db.collection("invites").document(inviteCode).getDocument()
            if let data = document.data(), let groupID = data["groupID"] as? String {
                return .success(groupID)
            } else {
                return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid invite code"]))
            }
        } catch {
            return .failure(error)
        }
    }
}
