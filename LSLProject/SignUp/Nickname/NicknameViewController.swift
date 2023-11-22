//
//  NicknameViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import RxSwift
import RxCocoa

final class NicknameViewController: MakeViewController {
    
    private let viewModel = NicknameViewModel()
    
    private let disposeBag = DisposeBag()
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "닉네임 만들기"
        descriptionLabel.text = "회원님만의 닉네임을 만드세요. 중복도 가능합니다!"
        customTextField.placeholder = "닉네임 (필수)"
        customTextField.keyboardType = .default
        
        guard let signUpValues else { return }
        
        bind(value: signUpValues)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let signUpValues else { return }
        
        print(#function, signUpValues)
        
    }
    
    private func bind(value: [String?]) {
        
        let input = NicknameViewModel.Input(inputText: customTextField.rx.text.orEmpty, nextButtonClicked: nextButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        var signUpValues = value
        
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
                owner.customTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
        
        output.borderStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.isHidden = value
                owner.customTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
        
        output.pushStatus
            .withLatestFrom(output.sendText, resultSelector: { _, value in
                return value
            })
            .withUnretained(self)
            .bind { owner, value in
                signUpValues.append(value)
                print("PhoneNumberViewController -> \(signUpValues)")
                owner.pushNextVieController(value: signUpValues)
                signUpValues.removeLast()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func pushNextVieController(value: [String?]) {
        print(value)
        view.endEditing(true)
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
