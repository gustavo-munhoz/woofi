//
//  HomeViewController.swift
//  woofi
//
//  Created by Gustavo Munhoz Correa on 06/05/24.
//

import UIKit
import Combine

class HomeViewController: UITabBarController, UIScrollViewDelegate {
    
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: HomeViewModel?
    var groupViewController = GroupViewController()
    var petListViewController = PetListViewController()
    var profileViewController = ProfileViewController()
    
    private(set) lazy var addButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .primary
        config.image = UIImage(systemName: "plus.circle.fill")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 22)
    
        let view = UIButton(configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let handler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
                case .highlighted:
                    button.alpha = 0.6
                default:
                    button.alpha = 1
            }
        }
        
        view.configurationUpdateHandler = handler
        view.accessibilityIdentifier = "addButton"
        
        if #available(iOS 17.0, *) { view.isSymbolAnimationEnabled = true }
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .systemBackground        
        
        groupViewController.tabBarItem = UITabBarItem(
            title: .localized(for: .homeVCGroupNavbarTitle),
            image: UIImage(systemName: "person.3.sequence.fill"),
            tag: 0
        )
        
        petListViewController.tabBarItem = UITabBarItem(
            title: .localized(for: .homeVCPetsNavbarTitle),
            image: UIImage(systemName: "pawprint.fill"),
            tag: 1
        )
        
        profileViewController.tabBarItem = UITabBarItem(
            title: .localized(for: .homeVCProfileNavbarTitle),
            image: UIImage(systemName: "person.fill"),
            tag: 2
        )
        
        viewControllers = [groupViewController, petListViewController, profileViewController]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        if selectedIndex != 2 {
            addButton.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addButton.isHidden = true
    }
    
    private func setupNavigationBar() {
        guard selectedIndex != 2 else {
            navigationItem.title = nil
            return
        }
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        navigationItem.title = selectedIndex == 0 ? .localized(for: .homeVCGroupNavbarTitle) : .localized(for: .homeVCPetsNavbarTitle)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.primary]
        
        setupAddButton()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard item.tag != 2 else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .edit,
                target: self,
                action: #selector(navigateToEditView)
            )
            
            navigationItem.title = nil
            addButton.isHidden = true
            return
        }
        
        navigationItem.rightBarButtonItem = nil
        addButton.isHidden = false
        if #available(iOS 17.0, *) {
            addButton.imageView?.addSymbolEffect(.bounce, options: .speed(4))
        }
        
        navigationItem.title = item.title
    }
    
    private func setupAddButton() {
        guard view.subviews.first(where: { $0.accessibilityIdentifier == "addButton"}) == nil else { return }
        
        if let navigationBar = navigationController?.navigationBar {
            UIView.animate(withDuration: 0.3) {
                navigationBar.addSubview(self.addButton)
                
                NSLayoutConstraint.activate([
                    self.addButton.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -16),
                    self.addButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                    self.addButton.widthAnchor.constraint(equalToConstant: 44),
                    self.addButton.heightAnchor.constraint(equalToConstant: 44)
                ])
            }
        }
    }
    
    @objc private func navigateToEditView() {
        guard let vm = profileViewController.viewModel else { 
            print("No UserViewModel in ProfileVC. Will not push EditProfileVC.")
            return
        }
        
        let vc = EditProfileViewController()
        vc.setViewModel(vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}
