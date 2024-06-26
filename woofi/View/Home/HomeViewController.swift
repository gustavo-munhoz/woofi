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
        
        addButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addButton.isHidden = true
    }
    
    private func setupNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = selectedIndex == 0 ? LocalizedString.Group.navbarTitle : LocalizedString.PetList.navbarTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.primary]
        
        setupAddButton()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
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
}
