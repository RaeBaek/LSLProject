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
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "이메일 주소 입력"
        descriptionLabel.text = "회원님에게 연락할 수 있는 이메일 주소를 입력하세요. 이 이메일 주소는 프로필에서 다른 사람에게 공개되지 않습니다."
        
        customTextField.placeholder = "이메일 주소 (필수)"
        
        bind()
        
    }
    
    func bind() {
        
        let input = EmailAddressViewModel.Input(inputText: customTextField.rx.text.orEmpty, nextButtonClicked: nextButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.borderStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.isHidden = value
                owner.customTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
        
        output.outputText
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.text = value
                owner.signUpValues?.append(value)
            }
            .disposed(by: disposeBag)
        
        output.textStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.isHidden = value
                owner.customTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
        
        output.pushStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.pushNextVieController()
            }
            .disposed(by: disposeBag)

    }
    
    @objc func pushNextVieController() {
        print(signUpValues)
        view.endEditing(true)
        let vc = PasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
