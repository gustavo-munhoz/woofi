//
//  User.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit

class User: Hashable, Codable {
    
    let id: String
    
    var username: String {
        didSet { savePersistedChanges() }
    }
    
    var bio: String? {
        didSet { savePersistedChanges() }
    }
    
    var email: String? {
        didSet { savePersistedChanges() }
    }
    
    var profilePicturePath: String? {
        didSet { savePersistedChanges() }
    }
    
    var groupID: String {
        didSet { savePersistedChanges() }
    }
        
    var stats: [UserTaskStat] {
        didSet { savePersistedChanges() }
    }
    
    var profilePicture: UIImage? {
        get {
            guard let path = profilePicturePath else { return nil }
            return UIImage(contentsOfFile: path)
        }
        set {
            if let image = newValue {
                let path = saveImageToDisk(image)
                profilePicturePath = path
            } else {
                profilePicturePath = nil
            }
        }
    }
    
    init(id: String, username: String, bio: String? = nil, email: String? = nil, groupID: String = UUID().uuidString, profilePicturePath: String? = nil) {
        self.id = id
        self.username = username
        self.bio = bio
        self.email = email
        self.groupID = groupID
        self.profilePicturePath = profilePicturePath
        self.stats = UserTaskStat.createAllWithZeroValue()
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case bio
        case email
        case groupID
        case profilePicturePath
        case stats
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        groupID = try container.decodeIfPresent(String.self, forKey: .groupID) ?? UUID().uuidString
        profilePicturePath = try container.decodeIfPresent(String.self, forKey: .profilePicturePath)
        stats = try container.decode([UserTaskStat].self, forKey: .stats)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(bio, forKey: .bio)
        try container.encode(email, forKey: .email)
        try container.encode(groupID, forKey: .groupID)
        try container.encode(profilePicturePath, forKey: .profilePicturePath)
        try container.encode(stats, forKey: .stats)
    }
    
    func savePersistedChanges() {
        guard self == Session.shared.currentUser else { return }
        
        UserDefaults.standard.saveUser(self)
    }
    
    private func saveImageToDisk(_ image: UIImage) -> String? {
        guard let data = image.pngData() else { return nil }
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = directory.appendingPathComponent("\(id)_profile.png")
        do {
            try data.write(to: path)
            return path.path
        } catch {
            print("Error saving image to disk: \(error)")
            return nil
        }
    }
}
