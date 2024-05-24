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
        DynamicLinksService.shared.generateDynamicLink { shortURL in
            guard let shortURL = shortURL else {
                
                return
            }
            
            let activityVC = UIActivityViewController(activityItems: [shortURL], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
