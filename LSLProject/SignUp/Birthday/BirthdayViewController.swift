//
//  BirthdayViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import RxSwift
import RxCocoa

class BirthdayViewController: MakeViewController {
    
    let skipButton = UIButton.signUpButton(title: "건너뛰기")
    
    let viewModel = BirthdayViewModel()
    
    let disposeBag = DisposeBag()
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "생년월일 입력"
        descriptionLabel.text = "비즈니스, 반려동물 또는 기타 목적으로 이 계정을 만드는 경우에도 회원님의 실제 생년월일을 사용하세요. 이 생년월일 정보는 회원님이 공유하지 않는 한 다른 사람에게 공개되지 않습니다."
        customTextField.placeholder = "생년월일 (선택)"
        customTextField.tintColor = .clear
        
        guard let signUpValues else { return }
        
        setUpDatePicker()
        
        bind(value: signUpValues)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let signUpValues else { return }
        
        print(#function, signUpValues)
        
    }
    
    func bind(value: [String?]) {
        
        let input = BirthdayViewModel.Input(inputText: customTextField.rx.text.orEmpty, nextButtonClicked: nextButton.rx.tap, skipButtonClicked: skipButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        var signUpValues = value
        
        output.sendText
            .withUnretained(self)
            .bind { owner, value in
                signUpValues.append(value)
                print("BirthdayMakeViewController -> \(signUpValues)")
                owner.pushNextVieController(value: signUpValues)
                signUpValues.removeLast()
            }
            .disposed(by: disposeBag)
        
    }
    
    func pushNextVieController(value: [String?]) {
        view.endEditing(true)
        let vc = CheckViewController()
        vc.signUpValues = value
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpDatePicker() {
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.addTarget(self, action: #selector(dateChange), for: .valueChanged)
        customTextField.inputView = datePicker
        customTextField.text = dateFormat(date: Date())
        
    }
    
    @objc func dateChange(_ sender: UIDatePicker) {
        customTextField.text = dateFormat(date: sender.date)
    }
    
    private func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        
        return formatter.string(from: date)
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
