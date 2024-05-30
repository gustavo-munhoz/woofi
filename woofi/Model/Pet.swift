//
//  Pet.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 10/05/24.
//

import Foundation
import UIKit
import Combine

class Pet: Hashable, Codable {
    let id: String
    let name: String
    let breed: String
    let age: String
    let picture: UIImage?
    var groupID: String?
    
    var dailyTasks: CurrentValueSubject<[PetTaskGroup], Never>
    var weeklyTasks: CurrentValueSubject<[PetTaskGroup], Never>
    var monthlyTasks: CurrentValueSubject<[PetTaskGroup], Never>
    
    init(
        id: String,
        name: String,
        breed: String,
        age: String,
        picture: UIImage? = nil,
        groupID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.picture = picture
        self.groupID = groupID
        self.dailyTasks = CurrentValueSubject(DefaultPetTaskStructure.dailyTasks())
        self.weeklyTasks = CurrentValueSubject(DefaultPetTaskStructure.weeklyTasks())
        self.monthlyTasks = CurrentValueSubject(DefaultPetTaskStructure.monthlyTasks())
    }
    
    static func == (_ lhs: Pet, _ rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breed
        case age
        case picture
        case groupID
        case dailyTasks
        case weeklyTasks
        case monthlyTasks
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        breed = try container.decode(String.self, forKey: .breed)
        age = try container.decode(String.self, forKey: .age)
        groupID = try container.decodeIfPresent(String.self, forKey: .groupID)
        
        if let pictureData = try container.decodeIfPresent(Data.self, forKey: .picture) {
            picture = UIImage(data: pictureData)
        } else {
            picture = nil
        }
        
        dailyTasks = CurrentValueSubject(try container.decode([PetTaskGroup].self, forKey: .dailyTasks))
        weeklyTasks = CurrentValueSubject(try container.decode([PetTaskGroup].self, forKey: .weeklyTasks))
        monthlyTasks = CurrentValueSubject(try container.decode([PetTaskGroup].self, forKey: .monthlyTasks))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(breed, forKey: .breed)
        try container.encode(age, forKey: .age)
        try container.encode(groupID, forKey: .groupID)
        
        if let picture = picture {
            let pictureData = picture.pngData()
            try container.encode(pictureData, forKey: .picture)
        }
        
        try container.encode(dailyTasks.value, forKey: .dailyTasks)
        try container.encode(weeklyTasks.value, forKey: .weeklyTasks)
        try container.encode(monthlyTasks.value, forKey: .monthlyTasks)
    }
}
