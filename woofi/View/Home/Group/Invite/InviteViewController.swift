//
//  InviteViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 23/05/24.
//

import UIKit

class InviteViewController: UIViewController {

    private let inviteView = InviteView()
    
    override func loadView() {
        view = inviteView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inviteView.sendButton.addTarget(self, action: #selector(sendInvite), for: .touchUpInside)
    }
    
    @objc private func sendInvite() {
        // Crie o link de convite
        let inviteLink = "https://example.com/invite"
        let activityVC = UIActivityViewController(activityItems: [inviteLink], applicationActivities: nil)
        
        // Apresentar o activity view controller
        present(activityVC, animated: true, completion: nil)
    }
}
