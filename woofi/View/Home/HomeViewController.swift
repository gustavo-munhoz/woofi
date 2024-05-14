//
//  HomeViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 06/05/24.
//

import UIKit

class HomeViewController: UITabBarController {
    
    var viewModel: HomeViewModel?
    var groupViewController = GroupViewController()
    var petListViewController = PetListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupViewController.tabBarItem = UITabBarItem(
            title: LocalizedString.Group.navbarTitle,
            image: UIImage(systemName: "person.3.sequence.fill"),
            tag: 0
        )
        
        petListViewController.tabBarItem = UITabBarItem(
            title: LocalizedString.PetList.navbarTitle,
            image: UIImage(systemName: "pawprint.fill"),
            tag: 1
        )
        
        viewControllers = [groupViewController, petListViewController]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = LocalizedString.Group.navbarTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.primary]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationItem.title = item.title
    }
}
