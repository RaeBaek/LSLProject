//
//  TokenCheckViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/23/23.
//

import UIKit
import RxSwift
import RxCocoa

class TokenCheckViewController: BaseViewController {
    
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
        let vc = check ? SignInViewController() : MainHomeViewController()
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc)
    }
    
    
}
