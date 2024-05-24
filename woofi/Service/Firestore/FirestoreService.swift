//
//  FirestoreService.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

import Foundation
import FirebaseFirestore

/// Shared singleton to handle Firestore logic, conforming to FirestoreServiceProtocol.
class FirestoreService: FirestoreServiceProtocol {
    
    /// Instance for global access
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
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
}
