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
    }
    
    private func setupActions() {
        joinGroupView.joinButton.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
    }
    
    @objc private func joinButtonTapped() {
        let inviteCode = joinGroupView.textFields.compactMap { $0.text }.joined()
        joinGroup(withInviteCode: inviteCode)
    }
    
    @objc private func joinGroup(withInviteCode inviteCode: String) {
        Task {
            let result = await FirestoreService.shared.fetchGroupID(forInviteCode: inviteCode)
            switch result {
            case .success(let groupID):
                if let currentUser = Session.shared.currentUser {
                    currentUser.groupID = groupID
                    do {
                        try await FirestoreService.shared.updateUserData(userId: currentUser.id, data: ["groupID": groupID])
                        print("Successfully updated groupID")

                        let res = await FirestoreService.shared.fetchUsersInSameGroup(groupID: currentUser.groupID)
                        switch res {
                        case .success(let users):
                            print("Users fetched: \(users.map { $0.id })")
                            Session.shared.cachedUsers.value = users
                            self.groupViewModel?.users.value = users

                        case .failure(let error):
                            print("Error fetching users: \(error.localizedDescription)")
                        }
                    } catch {
                        print("Error updating groupID: \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }

            case .failure(let error):
                print("Error fetching group ID: \(error.localizedDescription)")
                let alert = UIAlertController(
                    title: .localized(for: .joinGroupVCInvalidCodeTitle),
                    message: .localized(for: .joinGroupVCInvalidCodeMessage),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: .localized(for: .ok).uppercased(), style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
