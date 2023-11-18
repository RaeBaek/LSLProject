//
//  NicknameViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import RxSwift
import RxCocoa

class NicknameViewController: MakeViewController {
    
    let viewModel = NicknameViewModel()
    
    let disposeBag = DisposeBag()
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "닉네임 만들기"
        descriptionLabel.text = "회원님만의 닉네임을 만드세요. 중복도 가능합니다!"
        customTextField.placeholder = "닉네임 (필수)"
        
        guard let signUpValues else { return }
        
        bind(value: signUpValues)
        
    }
    
    func bind(value: [String?]) {
        
        let input = NicknameViewModel.Input(inputText: customTextField.rx.text.orEmpty, nextButtonClicked: nextButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        var signUpValues = value
        
        output.sendText
            .withUnretained(self)
            .bind { owner, value in
                signUpValues.append(value)
                owner.pushNextVieController(value: signUpValues)
            }
            .disposed(by: disposeBag)
        
    }
    
    func pushNextVieController(value: [String?]) {
        print(value)
        view.endEditing(true)
        print("------", value)
        let vc = PhoneNumberViewController()
        vc.signUpValues = value
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
