//
//  UserViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import UIKit
import Combine

class UserViewModel: NSObject {
    
    var user: User        
    
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var userPublisher = PassthroughSubject<User, Never>()
    
    init(user: User) {
        self.user = user
    }
    
    func listenToUserUpdates() {
        print("Listening to user updates on UserViewModel.")
        user.updatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] updatedUser in
                self?.user = updatedUser
                self?.userPublisher.send(updatedUser)
            }
            .store(in: &cancellables)
    }
    
    func updateUser(username: String?, bio: String?) {
        guard let name = username, let bio = bio else { return }
        
        user.username = name
        user.bio = bio
        
        Task {
            do {
                try await FirestoreService.shared.updateUserData(userId: user.id, data: [
                    FirestoreKeys.Users.username: name,
                    FirestoreKeys.Users.bio: bio
                ])
                print("User data updated successfully on Firestore.")
                userPublisher.send(user)
                
            } catch (let error) {
                print("Error Updating User on Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUserProfileImage(_ image: UIImage) {
        user.profilePicture = image
        Task {
            do {
                let profileImageUrl = try await FirestoreService.shared.saveProfileImage(
                    userID: user.id,
                    image: image
                )
                user.remoteProfilePicturePath = profileImageUrl
                userPublisher.send(user)
                print("User profile image URL updated successfully: \(profileImageUrl)")
            } catch (let error) {
                print("Error updating image URL: \(error.localizedDescription)")
            }
        }
    }
    
    func loadProfilePicture() {
        Task {
            guard let path = user.remoteProfilePicturePath,
                  let url = URL(string: path) else {
                print("Could not generate URL from user remote path.")
                return
            }
            do {
                let picture = try await FirestoreService.shared.fetchImage(from: url)
                user.setProfilePicture(picture)
                userPublisher.send(user)
                
            } catch {
                print("Error fetching profile picture: \(error.localizedDescription)")
            }
        }
    }
}
