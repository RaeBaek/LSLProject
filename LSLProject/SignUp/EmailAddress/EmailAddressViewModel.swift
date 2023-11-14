//
//  EmailAddressViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import Foundation
import RxSwift
import RxCocoa

class EmailAddressViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let inputText: ControlProperty<String>
        let nextButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let textStatus: PublishRelay<Bool>
        let outputText: BehaviorRelay<String>
        let buttonStatus: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let textStatus = PublishRelay<Bool>()
        let buttonStatus = PublishRelay<Bool>()
        
        let notValidation = BehaviorRelay(value: "유효한 이메일 주소를 입력하세요.")
        
        input.inputText
            .distinctUntilChanged()
            .map { $0.contains("@") }
            .bind { value in
                textStatus.accept(value)
                buttonStatus.accept(value)
            }
            .disposed(by: disposeBag)
        
        
        return Output(textStatus: textStatus, outputText: notValidation, buttonStatus: buttonStatus)
    }
}
