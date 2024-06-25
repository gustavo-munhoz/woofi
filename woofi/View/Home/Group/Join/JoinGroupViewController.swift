//
//  JoinGroupViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 24/05/24.
//

import UIKit

class JoinGroupViewController: UIViewController {
    
    weak var groupViewModel: GroupViewModel?
    
    private let joinGroupView = JoinGroupView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = joinGroupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
//        fetchInviterName()
    }
    
    private func setupActions() {
//        joinGroupView.acceptButton.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
//        joinGroupView.declineButton.addTarget(self, action: #selector(declineInvite), for: .touchUpInside)
    }

    private func fetchInviterName() {
//        Task {
//            do {
//                let userData = try await FirestoreService.shared.fetchUserData(userId: inviterId)
//                if let inviterName = userData["username"] as? String {
//                    DispatchQueue.main.async {
//                        self.joinGroupView.inviterLabel.text = "Invited by: \(inviterName)"
//                    }
//                }
//            } catch {
//                print("Error fetching inviter name: \(error)")
//            }
//        }
    }
    
    @objc private func joinGroup(withId groupID: String) {
        if let currentUser = Session.shared.currentUser {
            currentUser.groupID = groupID
            print("Successfully updated groupID")
            
            // Save the updated user data
            FirestoreService.shared.updateUserData(userId: currentUser.id, data: ["groupID": groupID]) { error in
                if let error = error {
                    print("Failed to update groupID: \(error)")
                } else {
                    Task {
                        let res =  await FirestoreService.shared.fetchUsersInSameGroup(groupID: currentUser.groupID!)
                        
                        switch res {
                            case .success(let users):
                                print("Users fetched: \(users.map { $0.id })")
                                Session.shared.cachedUsers.value = users
                                
                            case .failure(let error):
                                print("Error fetching users: \(error.localizedDescription)")
                                return
                        }
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }

    @objc private func declineInvite() {
        dismiss(animated: true, completion: nil)
    }
}
