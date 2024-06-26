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
                self.users.value = users
                
            case .failure(let error):
                print("Error loading users: \(error)")
        }
    }
    
    func navigateToUser(_ user: User) {
        navigateToUserPublisher.send(user)
    }
    
    private func setupSubscriptions() {
        // TODO: Verificar se isso funciona
        Session.shared.cachedUsers
            .sink { [weak self] users in
                guard !users.isEmpty else { return }
                
                self?.users.value = users
            }
            .store(in: &cancellables)
    }
}
