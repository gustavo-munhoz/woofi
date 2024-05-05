//
//  FirestoreServiceProtocol.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 05/05/24.
//

/// Protocol to define Firestore operations
protocol FirestoreServiceProtocol {
    func saveUserData(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void)
    func fetchUserData(userId: String, completion: @escaping (Result<[String:Any], Error>) -> Void)
    func updateUserData(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void)
    func removeUser(userId: String, completion: @escaping (Error?) -> Void)
}
