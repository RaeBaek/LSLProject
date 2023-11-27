//
//  BirthdayViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import RxSwift
import RxCocoa

final class BirthdayViewController: MakeViewController {
    
    private lazy var datePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .date
        view.preferredDatePickerStyle = .wheels
        view.locale = Locale(identifier: "ko-KR")
        customTextField.inputView = view
        
        return view
    }()
    
    private let skipButton = UIButton.signUpButton(title: "건너뛰기")
    
    private let viewModel = BirthdayViewModel(repository: NetworkRepository())
    
    private let disposeBag = DisposeBag()
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "생년월일 입력"
        descriptionLabel.text = "비즈니스, 반려동물 또는 기타 목적으로 이 계정을 만드는 경우에도 회원님의 실제 생년월일을 사용하세요. 이 생년월일 정보는 회원님이 공유하지 않는 한 다른 사람에게 공개되지 않습니다."
        customTextField.placeholder = "생년월일 (선택)"
        customTextField.tintColor = .clear
        
        guard let signUpValues else { return }
        
        bind(value: signUpValues)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let signUpValues else { return }
        
        print(#function, signUpValues)
        
    }
    
    private func bind(value: [String?]) {
        
        var signUpValues = value
        
        let input = BirthdayViewModel.Input(signUpValues: Observable.of(signUpValues), inputText: datePicker.rx.value, nextButtonClicked: nextButton.rx.tap, skipButtonClicked: skipButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.textStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
        output.borderStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.customTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
        
        output.outputText
            .withUnretained(self)
            .bind { owner, value in
                owner.customTextField.text = value
            }
            .disposed(by: disposeBag)
        
        output.statusText
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.text = value
            }
            .disposed(by: disposeBag)
        
        output.signUpStatus
            .withUnretained(self)
            .debug()
            .bind { owner, value in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func changeRootViewController() {
        let rootVC = UINavigationController(rootViewController: MainTabBarController())
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(rootVC)
        
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
