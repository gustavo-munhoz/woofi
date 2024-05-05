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
    
    /// Saves user data to Firestore with a server-side timestamp
    func saveUserData(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        var userData = data
        userData[FirestoreKeys.Users.createdAt] = FieldValue.serverTimestamp()
        
        db.collection(FirestoreKeys.Users.collectionTitle).document(userId).setData(userData, completion: completion)
    }
    
    /// Fetches user data from Firestore
    func fetchUserData(userId: String, completion: @escaping (Result<[String:Any], Error>) -> Void) {
        db.collection(FirestoreKeys.Users.collectionTitle).document(userId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists, let data = document.data() {
                completion(.success(data))
            } else {
                let error = NSError(domain: "FirestoreService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data found"])
                completion(.failure(error))
            }
        }
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
