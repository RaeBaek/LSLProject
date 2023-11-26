//
//  TokenCheckViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/23/23.
//

import UIKit
import RxSwift
import RxCocoa

final class TokenCheckViewController: BaseViewController {
    
    let viewModel = TokenCheckViewModel(repository: NetworkRepository())
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        let input = TokenCheckViewModel.Input(token: BehaviorRelay(value: UserDefaultsManager.token))
        let output = viewModel.transform(input: input)
        
        output.check
            .withUnretained(self)
            .bind { owner, value in
                print("현재 값 \(value)")
                if let value {
                    owner.changeRootViewController(check: value)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
    private func changeRootViewController(check: Bool) {
        
        if check {
            let vc = SignInViewController()
            
            let rootVC = UINavigationController(rootViewController: vc)
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(rootVC)
            
        } else {
            let homeVC = UINavigationController(rootViewController: HomeViewController())
            let searchVC = UINavigationController(rootViewController: SearchViewController())
            let postVC = UINavigationController(rootViewController: PostViewController())
            let heartVC = UINavigationController(rootViewController: HeartViewController())
            let userVC = UINavigationController(rootViewController: UserViewController())
            
            let tabBC = UITabBarController()
            tabBC.setViewControllers([homeVC, searchVC, postVC, heartVC, userVC], animated: true)
            
            tabBC.tabBar.tintColor = .black
            
            if let items = tabBC.tabBar.items {
                
                let barImages = ["home", "search", "post", "heart", "user"]
                let barSelectImages = ["home.fill", "search.fill", "post.fill", "heart.fill", "user.fill"]
                
                for i in 0..<5 {
                    items[i].image = UIImage(named: barImages[i])
                    items[i].selectedImage = UIImage(named: barSelectImages[i])
                    items[i].imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
                }
                
            }
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(tabBC)
        }
        
    }
    
}
