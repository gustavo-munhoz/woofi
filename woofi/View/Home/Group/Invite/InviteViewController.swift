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
        let groupID = currentUser.groupID ?? "0"
        code = generateSimplifiedID(from: groupID)
        
        inviteView.setCodeText(code)
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

    
    func generateSimplifiedID(from groupID: String) -> String {
        let hashData = groupID.sha256()
        let base36String = hashData.base36EncodedString()
        
        let simplifiedID = String(base36String.prefix(6))
        return simplifiedID
    }
}
