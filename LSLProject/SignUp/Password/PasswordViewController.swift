//
//  PasswordViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import RxSwift
import RxCocoa

class PasswordViewController: MakeViewController {
    
    let viewModel = PasswordViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "비밀번호 입력"
        descriptionLabel.text = "다른 사람이 추측할 수 없는 6자 이상의 문자 또는 숫자로 비밀번호를 만드세요."
        customTextField.placeholder = "비밀번호 (필수)"
        
        bind()
        
    }
    
    func bind() {
        let input = PasswordViewModel.Input(inputText: customTextField.rx.text.orEmpty, nextButtonClicked: nextButton.rx.tap)
        
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
        view.endEditing(true)
        let vc = NicknameViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
