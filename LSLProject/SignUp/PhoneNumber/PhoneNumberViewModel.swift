//
//  PhoneNumberViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/16/23.
//

import Foundation
import RxSwift
import RxCocoa

class PhoneNumberViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let inputText: ControlProperty<String>
        let nextButtonClicked: ControlEvent<Void>
        let skipButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let textStatus : PublishRelay<Bool>
        let pushStatus : PublishRelay<Bool>
        let borderStatus : PublishRelay<Bool>
        let outputText : PublishRelay<String>
        let sendText : PublishRelay<String?>
    }
    
    func transform(input: Input) -> Output {
        
        let textStatus = PublishRelay<Bool>()
        let pushStatus = PublishRelay<Bool>()
        let borderStatus = PublishRelay<Bool>()
        let outputText = PublishRelay<String>()
        let sendText = PublishRelay<String?>()
        
        let inputText = input.inputText
                                   .share()
        inputText
            .distinctUntilChanged()
            .map { _ in
                return true
            }
            .bind(to: borderStatus, textStatus)
            .disposed(by: disposeBag)
        
        inputText
//            .distinctUntilChanged()
            .bind { value in
                if value.count > 11 { // 번호가 11자리보다 길어지면 안되므로 if 문 처리
                    let index = value.index(value.startIndex, offsetBy: 11)
                    sendText.accept(String(value[..<index]))
                } else { // 11자리까지 문제없이 기입하였는데 accept를 해주지 않으면 구독을 할 수가 없다.
                    sendText.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        input.nextButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.inputText) { _, text in
                return text
            }
            .map { $0.count < 11 }
            .bind { value in
                textStatus.accept(!value)
                borderStatus.accept(!value)
                outputText.accept("올바른 휴대폰 번호를 입력해주세요!")
                if value == false {
                    pushStatus.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        input.skipButtonClicked
            .bind { _ in
                sendText.accept(nil)
                pushStatus.accept(true)
            }
            .disposed(by: disposeBag)
        
        return Output(textStatus: textStatus, pushStatus: pushStatus, borderStatus: borderStatus, outputText: outputText, sendText: sendText)
    }
    
}
