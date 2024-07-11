//
//  InviteViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 23/05/24.
//

import UIKit

class InviteViewController: UIViewController {

    private let inviteView = InviteView()
    
    private var code: String!
    
    override func loadView() {
        view = inviteView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteView.sendButton.addTarget(self, action: #selector(sendInvite), for: .touchUpInside)
        
        guard let currentUser = Session.shared.currentUser else { return }
        let groupID = currentUser.groupID
        
        Task {
            let result = await FirestoreService.shared.generateInviteCode(forGroupID: groupID)
            
            switch result {
                case .success(let success):
                    code = success
                    inviteView.setCodeText(code)
                    
                case .failure(let failure):
                    print("Error generating invite code: \(failure.localizedDescription)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func sendInvite() {
        guard let code = code else { return }
        
        let inviteMessage = "Join my Woofy group using this code: \(code)"
        
        let activityVC = UIActivityViewController(activityItems: [inviteMessage], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }        
}
