//
//  MainHomeViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/19/23.
//

import UIKit
import RxSwift
import RxCocoa

final class MainHomeViewController: BaseViewController {
    
    private let checkLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 30, weight: .regular)
        return view
    }()
    
    private let withdrawButton = {
        let view = UIButton()
        view.setTitle("회원탈퇴", for: .normal)
        view.backgroundColor = .lightGray
        view.tintColor = .yellow
        return view
    }()
    
    let viewModel = MainHomeViewModel(repository: NetworkRepository())
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLabel.text = "메인 홈~~"
        
        bind()
        
    }
    
    func bind() {
        let input = MainHomeViewModel.Input(withdraw: withdrawButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.check
            .withUnretained(self)
            .bind { owner, value in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func changeRootViewController() {
        let vc = SignInViewController()
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc)
    }
    
    override func configureView() {
        super.configureView()
        
        view.backgroundColor = .systemBackground
        
        [checkLabel, withdrawButton].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        checkLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        withdrawButton.snp.makeConstraints {
            $0.top.equalTo(checkLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        }
        
    }
    
}
