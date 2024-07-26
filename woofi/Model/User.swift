//
//  User.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit
import Combine

class User: Hashable {
    
    private(set) var updatePublisher = PassthroughSubject<User, Never>()
    private(set) var leaveGroupPublisher = PassthroughSubject<Bool, Never>()
    
    let id: String
    
    var username: String?
    
    var bio: String?
    
    var email: String?
    
    var remoteProfilePicturePath: String? {
        didSet {
            if let path = remoteProfilePicturePath,
               let url = URL(string: path) {
                setProfilePicture(from: url)
            }
        }
    }
    
    var groupID: String
        
    var stats: [UserTaskStat]
    
    var profilePicture: UIImage?
    
    init(
        id: String,
        username: String? = .localized(for: .placeholderUsername),
        bio: String? = .localized(for: .placeholderBio),
        email: String? = nil,
        remoteProfilePicturePath: String? = nil,
        groupID: String = UUID().uuidString,
        stats: [UserTaskStat]? = nil
    ) {
        self.id = id
        self.username = username
        self.bio = bio
        self.email = email
        self.groupID = groupID
        self.remoteProfilePicturePath = remoteProfilePicturePath
        self.stats = stats ?? UserTaskStat.createAllWithZeroValue()
    }
    
    func setProfilePicture(from url: URL) {
        Task {
            do {
                let image = try await FirestoreService.shared.fetchImage(from: url)
                setProfilePicture(image)
                
            } catch {
                print("Error fetching profile picture: \(error.localizedDescription)")
                setProfilePicture(UIImage(systemName: "person.crop.fill")!)
            }
        }
    }
    
    func setProfilePicture(_ image: UIImage) {
        self.profilePicture = image
    }
    
    static func ==(_ lhs: User, _ rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func publishSelf() {
        print("Sending user update.")
        updatePublisher.send(self)
    }
    
    func publishLeavingGroup() {
        leaveGroupPublisher.send(true)
    }
}
