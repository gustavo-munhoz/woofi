//
//  FirestoreService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
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
    
    func checkIfUserExists(id: String) async throws -> Bool {
        let snapshot = try await db.collection(FirestoreKeys.Users.collectionTitle)
            .whereField(FirestoreKeys.Users.uid, isEqualTo: id)
            .getDocuments()
        
        return !snapshot.isEmpty
    }
    
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
    
    func fetchUser(for id: UserId) async throws -> User {
        let data = try await fetchUserData(userId: id)
     
        let id: String = data[FirestoreKeys.Users.uid] as! String
        let username = data[FirestoreKeys.Users.username] as? String
        let bio = data[FirestoreKeys.Users.bio] as? String
        let email = data[FirestoreKeys.Users.email] as? String
        let picturePath = data[FirestoreKeys.Users.profileImageUrl] as? String
        let groupId = data[FirestoreKeys.Users.groupID] as! String
        let stats: [UserTaskStat]?
        
        if let statsData = data[FirestoreKeys.Users.Stats.title] as? [String: Int] {
            stats = UserTaskStat.createFromDictionary(statsData)
        } else {
            stats = nil
        }
        
        return User(
            id: id,
            username: username,
            bio: bio,
            email: email,
            remoteProfilePicturePath: picturePath,
            groupID: groupId,
            stats: stats
        )
    }
    
    /// Fetches all users related to the same group as the current user
    func fetchUsersInSameGroup(groupID: String) async -> Result<[User], Error> {
        do {
            print("Fetching users for group id: \(groupID)")
            
            let querySnapshot = try await db.collection(FirestoreKeys.Users.collectionTitle)
                .whereField(FirestoreKeys.Users.groupID, isEqualTo: groupID)
                .getDocuments()
            
            var users = [User]()
            var fetchUserTasks: [Task<User, Error>] = []
            
            for document in querySnapshot.documents {
                if let userId = document.data()[FirestoreKeys.Users.uid] as? String,
                   userId != Session.shared.currentUser?.id {
                    let fetchUserTask = Task {
                        try await fetchUser(for: userId)
                    }
                    fetchUserTasks.append(fetchUserTask)
                }
            }
            
            // Await all fetch user tasks and collect the results
            for task in fetchUserTasks {
                do {
                    let user = try await task.value
                    users.append(user)
                } catch {
                    print("Error fetching user: \(error.localizedDescription)")
                    return .failure(error)
                }
            }
            
            let sortedUsers = users.sortedByUsername()
            return .success(sortedUsers)
            
        } catch {
            return .failure(error)
        }
    }
    
    /// Saves user data to Firestore with a server-side timestamp
    func saveUserData(userId: String, data: [String: Any]) async throws {
        var userData = data
        userData[FirestoreKeys.Users.createdAt] = FieldValue.serverTimestamp()
        
        try await db.collection(FirestoreKeys.Users.collectionTitle).document(userId).setData(userData)
    }
    
    /// Updates user data in Firestore
    func updateUserData(userId: String, data: [String: Any]) async throws {
        let documentRef = db.collection(FirestoreKeys.Users.collectionTitle).document(userId)
        try await documentRef.updateData(data)
    }
    
    func updateUserStats(for user: User) async throws {
        var data: [String: Any] = [:]
        
        let tasks: [TaskType] = [.walk, .feed, .brush, .bath, .vet]
        
        for task in tasks {
            if let stat = user.stats.first(where: { $0.task == task }) {
                switch task {
                case .walk:
                    data[FirestoreKeys.Users.Stats.walk] = stat.value
                case .feed:
                    data[FirestoreKeys.Users.Stats.feed] = stat.value
                case .brush:
                    data[FirestoreKeys.Users.Stats.brush] = stat.value
                case .bath:
                    data[FirestoreKeys.Users.Stats.bath] = stat.value
                case .vet:
                    data[FirestoreKeys.Users.Stats.vet] = stat.value
                }
            }
        }
        
        let dataWrapper = [FirestoreKeys.Users.Stats.title: data]
        
        if !data.isEmpty {
            try await self.updateUserData(userId: user.id, data: dataWrapper)
        } else {
            throw NSError(
                domain: "UpdateUserStatsError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No stats available to update."]
            )
        }
    }
    
    /// Removes a user from Firestore
    func removeUser(userId: String, completion: @escaping (Error?) -> Void) {
        db.collection(FirestoreKeys.Users.collectionTitle).document(userId).delete(completion: completion)
    }
    
    func saveProfileImage(userID: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(
                domain: "ImageError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."]
            )
        }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        let profileImageUrl = downloadURL.absoluteString
        try await FirestoreService.shared.updateUserData(userId: userID, data: ["profileImageUrl": profileImageUrl])
        
        return profileImageUrl
    }
    
    /// Saves pet data to firestore with a server-side timestamp.
    func savePetData(petId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        logger.log("Saving pet data for id: \(petId)")
        
        var petData = data
        petData[FirestoreKeys.Pets.createdAt] = FieldValue.serverTimestamp()
        petData["lastUpdatedByUserId"] = Session.shared.currentUser?.id
        
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
    func updatePetData(petId: String, data: [String: Any]) async throws {
        try await db.collection(FirestoreKeys.Pets.collectionTitle).document(petId).updateData(data)
    }
    
    /// Removes a pet from Firestore
    func removePet(petId: String) async throws {
        try await db.collection(FirestoreKeys.Pets.collectionTitle).document(petId).delete()
    }
    
    func updateTaskInstance(petID: String, frequency: TaskFrequency, petTaskGroup: PetTaskGroup, taskInstance: PetTaskInstance, completion: @escaping (Error?) -> Void) {
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
            petData["lastUpdatedByUserId"] = Session.shared.currentUser?.id
            
            var taskGroups = petData[taskGroupField] as? [[String: Any]] ?? []
            
            if let taskGroupIndex = taskGroups.firstIndex(where: { ($0["id"] as? String) == petTaskGroup.id.uuidString }) {
                var taskGroup = taskGroups[taskGroupIndex]
                
                var instances = taskGroup["instances"] as? [[String: Any]] ?? []
                
                if let taskInstanceIndex = instances.firstIndex(where: { ($0["id"] as? String) == taskInstance.id.uuidString }) {
                    do {
                        let jsonData = try JSONEncoder().encode(taskInstance)
                        if var jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            jsonObject["frequency"] = frequency.rawValue
                            jsonObject["task"] = petTaskGroup.task.rawValue
                            instances[taskInstanceIndex] = jsonObject
                        }
                    } catch {
                        completion(error)
                        return
                    }
                } else {
                    do {
                        let jsonData = try JSONEncoder().encode(taskInstance)
                        if var jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            jsonObject["frequency"] = frequency.rawValue
                            jsonObject["task"] = petTaskGroup.task.rawValue
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
                var newTaskGroup: [String: Any] = [
                    "id": petTaskGroup.id.uuidString,
                    "frequency": frequency
                ]
                do {
                    let jsonData = try JSONEncoder().encode(taskInstance)
                    if var jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        jsonObject["frequency"] = frequency.rawValue
                        jsonObject["task"] = petTaskGroup.task.rawValue
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

    /// Add listeners to pet. Returns a
    func addPetsListener(groupID: String, onUpdate: @escaping (Result<[String: Pet], Error>) -> Void) {
        let petsRef = db.collection(FirestoreKeys.Pets.collectionTitle).whereField("groupID", isEqualTo: groupID)
        
        let listener = petsRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                onUpdate(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                onUpdate(.success([:]))
                return
            }
            
            Task {
                do {
                    var petsAndUserResponsible: [String: Pet] = [:]
                    
                    for document in documents {
                        var data = document.data()
                        
                        guard let updateId = data["lastUpdatedByUserId"] as? String else { continue }
                        
                        // Remove fields that could break decoding
                        data.removeValue(forKey: "lastUpdatedByUserId")
                        data.removeValue(forKey: "createdAt")
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let pet = try JSONDecoder().decode(Pet.self, from: jsonData)
                        
                        if let pictureURLString = pet.pictureURL,
                           let pictureURL = URL(string: pictureURLString) {
                            do {
                                let image = try await self.fetchImage(from: pictureURL)
                                pet.picture = image
                            } catch {
                                print("Failed to fetch image: \(error)")
                            }
                        }
                        
                        petsAndUserResponsible[updateId] = pet
                    }
                    
                    onUpdate(.success(petsAndUserResponsible))
                } catch {
                    onUpdate(.failure(error))
                }
            }
        }
        
        petListeners.append(listener)
    }


    func savePetImage(petId: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(
                domain: "ImageError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."]
            )
        }
        
        let storageRef = Storage.storage().reference().child("pet_images/\(petId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        let petImageUrl = downloadURL.absoluteString
        
        try await updatePetData(petId: petId, data: [
            FirestoreKeys.Pets.pictureURL: petImageUrl
        ])
        
        return petImageUrl
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            return image
        } else {
            throw NSError(domain: "ImageErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create image from data."])
        }
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
