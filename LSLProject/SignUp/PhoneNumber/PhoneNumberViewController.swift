//
//  PhoneNumberViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import RxSwift
import RxCocoa

class PhoneNumberViewController: MakeViewController {
    
    let skipButton = UIButton.signUpButton(title: "건너뛰기")
    
    let viewModel = PhoneNumberViewModel()
    
    let disposeBag = DisposeBag()
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "휴대폰 번호 입력"
        descriptionLabel.text = "회원님에게 연락할 수 있는 휴대폰 번호를 입력하세요. 이 휴대폰 번호는 프로필에서 다른 사람에게 공개되지 않습니다."
        customTextField.placeholder = "휴대폰 번호 (선택)"
        
        guard let signUpValues else { return }
        
        bind(value: signUpValues)
        
    }
    
    func bind(value: [String?]) {
        
        var signUpValues = value
        
        let input = PhoneNumberViewModel.Input(inputText: customTextField.rx.text.orEmpty, nextButtonClicked: nextButton.rx.tap, skipButtonClicked: skipButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.sendText
            .withUnretained(self)
            .bind { owner, value in
                signUpValues.append(value)
                owner.pushNextVieController(value: signUpValues)
            }
            .disposed(by: disposeBag)
        
    }
    
    func pushNextVieController(value: [String?]) {
        view.endEditing(true)
        print("------", value)
        let vc = BirthdayMakeViewController()
        vc.signUpValues = value
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
        view.addSubview(skipButton)
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        skipButton.snp.makeConstraints {
            $0.top.equalTo(nextButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaInsets).inset(16)
            $0.height.equalTo(45)
        }
        
    }
    
}
