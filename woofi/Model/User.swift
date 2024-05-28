//
//  User.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit

class User: Hashable, Codable {
    
    let id: String
    var username: String
    var bio: String?
    var profilePicture: UIImage?
    var groupID: String?
    
    var stats: [UserTaskStat]
    
    init(id: String, username: String, bio: String? = nil, groupID: String? = nil, profilePicture: UIImage? = nil) {
        self.id = id
        self.username = username
        self.bio = bio
        self.groupID = groupID
        self.profilePicture = profilePicture
        self.stats = UserTaskStat.createAllWithZeroValue()
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
        case groupID
        case profilePicture
        case stats
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        groupID = try container.decodeIfPresent(String.self, forKey: .groupID)
        if let profilePictureData = try container.decodeIfPresent(Data.self, forKey: .profilePicture) {
            profilePicture = UIImage(data: profilePictureData)
        } else {
            profilePicture = nil
        }
        stats = try container.decode([UserTaskStat].self, forKey: .stats)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(bio, forKey: .bio)
        try container.encode(groupID, forKey: .groupID)
        if let profilePicture = profilePicture {
            let profilePictureData = profilePicture.pngData()
            try container.encode(profilePictureData, forKey: .profilePicture)
        }
        try container.encode(stats, forKey: .stats)
    }
}

