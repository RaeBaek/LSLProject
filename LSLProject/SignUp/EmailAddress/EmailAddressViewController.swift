//
//  EmailAddressViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/13/23.
//

import UIKit
import RxSwift
import RxCocoa

class EmailAddressViewController: MakeViewController {
    
    let viewModel = EmailAddressViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "이메일 주소 만들기"
        descriptionLabel.text = "사용자 이름을 추가하거나 추천 이름을 사용하세요. 언제든지 변경할 수 있습니다."
        
        customTextField.placeholder = "이메일 주소 (필수)"
        
        nextButton.addTarget(self, action: #selector(pushNextVieController), for: .touchUpInside)
        
        bind()
        
    }
    
    func bind() {
        let buttonStatus = BehaviorRelay(value: false)
        
        let input = EmailAddressViewModel.Input(inputText: customTextField.rx.text.orEmpty, nextButtonClicked: nextButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.outputText
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.text = value
            }
            .disposed(by: disposeBag)
        
        output.textStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
        output.buttonStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.nextButton.isEnabled = value
            }
            .disposed(by: disposeBag)
        
        
    }
    
    @objc func pushNextVieController() {
        view.endEditing(true)
        let vc = PasswordMakeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
