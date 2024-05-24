//
//  JoinGroupViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 24/05/24.
//

import UIKit

class JoinGroupViewController: UIViewController {

    private let joinGroupView = JoinGroupView()
    private let groupId: String
    private let inviterId: String
    
    init(groupId: String, inviterId: String) {
        self.groupId = groupId
        self.inviterId = inviterId
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
        fetchInviterName()
    }
    
    private func setupActions() {
        joinGroupView.acceptButton.addTarget(self, action: #selector(acceptInvite), for: .touchUpInside)
        joinGroupView.declineButton.addTarget(self, action: #selector(declineInvite), for: .touchUpInside)
    }

    private func fetchInviterName() {
        Task {
            do {
                let userData = try await FirestoreService.shared.fetchUserData(userId: inviterId)
                if let inviterName = userData["username"] as? String {
                    DispatchQueue.main.async {
                        self.joinGroupView.inviterLabel.text = "Invited by: \(inviterName)"
                    }
                }
            } catch {
                print("Error fetching inviter name: \(error)")
            }
        }
    }
    
    @objc private func acceptInvite() {
        if var currentUser = Session.shared.currentUser {
            currentUser.groupID = groupId
            // Save the updated user data
            FirestoreService.shared.updateUserData(userId: currentUser.id, data: ["groupID": groupId]) { error in
                if let error = error {
                    print("Failed to update groupID: \(error)")
                } else {
                    print("Successfully updated groupID")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }

    @objc private func declineInvite() {
        dismiss(animated: true, completion: nil)
    }
}
