//
//  GroupViewModel.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 07/05/24.
//

import Foundation
import Combine

class GroupViewModel: NSObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading = true
    
    /// The current list of users related to the main app user.
    var users = CurrentValueSubject<[User], Never>.init([])
    
    /// Sends a signal to change the current view to a `UserView`.
    private(set) var navigateToUserPublisher = PassthroughSubject<User, Never>()
    
    override init() {
        super.init()
        
        Task {
            await loadUsers()
        }
        setupSubscriptions()
    }
    
    /// Loads related users from firestore.
    func loadUsers() async {
        guard let groupID = Session.shared.currentUser?.groupID else { return }
        
        let result = await FirestoreService.shared.fetchUsersInSameGroup(groupID: groupID)
        
        switch result {
        case .success(let users):
            print("Users fetched: \(users.map { $0.id })")
            self.isLoading = false
            self.users.value = users
            
        case .failure(let error):
            print("Error loading users: \(error)")
        }
    }
    
    func navigateToUser(_ user: User) {
        navigateToUserPublisher.send(user)
    }
    
    func leaveGroup() {
        guard let currentUser = Session.shared.currentUser else { return }
        currentUser.groupID = UUID().uuidString
        
        Task {
            do {
                try await FirestoreService.shared.updateUserData(
                    userId: currentUser.id,
                    data: [FirestoreKeys.Users.groupID: currentUser.groupID]
                )
                
                Session.shared.currentUser?.publishLeavingGroup()
                users.value = []
                
            } catch {
                print("Error leaving group: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupSubscriptions() {
        Session.shared.cachedUsers
            .sink { [weak self] users in
                guard !users.isEmpty else { return }
                
                self?.users.value = users
            }
            .store(in: &cancellables)
    }
    
    func refreshGroup() async {
        await loadUsers()
    }
}
