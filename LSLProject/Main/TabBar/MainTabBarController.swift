//
//  MainTabBarController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/27/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        self.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        setTabBar()
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setTabBar() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let postVC = UINavigationController(rootViewController: PostViewController())
        let heartVC = UINavigationController(rootViewController: HeartViewController())
        let userVC = UINavigationController(rootViewController: MyProfileViewController())
        
        self.setViewControllers([homeVC, searchVC, postVC, heartVC, userVC], animated: true)
        
        self.tabBar.tintColor = .black
        
        
        if let items = self.tabBar.items {
            
            let barImages = ["home", "search", "post", "heart", "user"]
            let barSelectImages = ["home.fill", "search.fill", "post.fill", "heart.fill", "user.fill"]
            
            for i in 0..<5 {
                items[i].tag = i
                items[i].image = UIImage(named: barImages[i])
                items[i].selectedImage = UIImage(named: barSelectImages[i])
                items[i].imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            }
            
        }
        
    }
    
    @objc private func modalPostViewController() {
        let postVC = UINavigationController(rootViewController: PostViewController())
        postVC.modalPresentationStyle = .automatic
        self.present(postVC, animated: true)
    }

}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 2 {
            modalPostViewController()
            return false
        } else {
            return true
        }
    }
    
}
