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
    
    struct Input {
        let inputText: ControlProperty<String>
        let nextButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let textStatus: PublishRelay<Bool>
        let pushStatus: PublishRelay<Bool>
        let outputText: PublishRelay<String>
        let borderStatus: PublishRelay<Bool>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let textStatus = PublishRelay<Bool>()
        let pushStatus = PublishRelay<Bool>()
        let statusCode = PublishRelay<Int>()
        let outputText = PublishRelay<String>()
        let borderStatus = PublishRelay<Bool>()
        
        input.inputText
            .distinctUntilChanged()
            .map { _ in
                return true
            }
            .bind { value in
                borderStatus.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.nextButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.inputText) { _, text in
                print(text)
                return text
            }
            .bind { value in
                APIManager.shared.emailValidationAPI(email: value) { code, message in
                    statusCode.accept(code)
                    outputText.accept(message)
                }
            }
            .disposed(by: disposeBag)
        
        statusCode
            .map { $0 == 200 }
            .bind { value in
                textStatus.accept(value)
                if value == true {
                    pushStatus.accept(value)
                    print(value)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(textStatus: textStatus, pushStatus: pushStatus, outputText: outputText, borderStatus: borderStatus)
    }
    
}
