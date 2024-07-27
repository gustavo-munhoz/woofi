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
        
        if let path = remoteProfilePicturePath,
           let url = URL(string: path) {
            setProfilePicture(from: url)
        }
    }
    
    func setProfilePicture(from url: URL) {
        Task {
            do {
                let image = try await FirestoreService.shared.fetchImage(from: url)
                setProfilePicture(image)
                publishSelf()
            } catch {
                print("Error fetching profile picture: \(error.localizedDescription)")
                setProfilePicture(UIImage(systemName: "person.crop.fill")!)
            }
        }
    }
    
    func setProfilePicture(_ image: UIImage) {
        self.profilePicture = image
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
       return lhs.id == rhs.id
        && lhs.username == rhs.username
        && lhs.bio == rhs.bio
        && lhs.email == rhs.email
        && lhs.groupID == rhs.groupID
        && lhs.profilePicture == rhs.profilePicture
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(username)
        hasher.combine(bio)
        hasher.combine(email)
        hasher.combine(groupID)
        if let profilePicture = profilePicture {
            hasher.combine(profilePicture.pngData())
        }
    }
    
    func publishSelf() {
        print("Sending user update.")
        updatePublisher.send(self)
    }
    
    func publishLeavingGroup() {
        leaveGroupPublisher.send(true)
    }
}

extension Array where Element: User {
    func sortedByUsername() -> Self {
        return self.sorted(by: { $0.username!.lowercased() < $1.username!.lowercased() })
    }
}
