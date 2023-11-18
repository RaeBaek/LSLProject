//
//  PasswordViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/15/23.
//

import Foundation
import RxSwift
import RxCocoa

class PasswordViewModel {
    
    struct Input {
        let inputText: ControlProperty<String>
        let nextButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let textStatus: BehaviorRelay<Bool>
        let pushStatus: PublishRelay<Bool>
        let outputText: BehaviorRelay<String>
        let borderStatus: PublishRelay<Bool>
        let sendText: PublishRelay<String>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let textStatus = BehaviorRelay(value: false)//PublishRelay<Bool>()
        let pushStatus = PublishRelay<Bool>()
        let borderStatus = PublishRelay<Bool>()
        let sendText = PublishRelay<String>()
        
        let empty = ""
        let emptyMessage = "비밀번호는 비워둘 수 없습니다."
        let modifyMessage = "비밀번호의 보안수준이 낮습니다. 비밀번호는 숫자로만 구성할 수 없으며 6자리 이상의 문자와 숫자 조합으로 더 긴 비밀번호를 만드세요."
        
        let outputText = BehaviorRelay(value: empty)
        
        input.inputText
            .distinctUntilChanged()
            .map { _ in
                return true
            }
            .bind(to: borderStatus)
            .disposed(by: disposeBag)
        
        input.inputText
            .distinctUntilChanged()
            .bind(to: sendText)
            .disposed(by: disposeBag)
        
        input.inputText
            .map { value -> Bool in
                print(value)
                if let value = Int(value) {
                    print("inputText: \(value)")
                    return false
                } else {
                    if value.count >= 6 {
                        return true
                    }
                    return false
                }
            }
            .bind(to: textStatus)
            .disposed(by: disposeBag)
        
        input.inputText
            .map { $0 == "" }
            .bind { value in
                print("빈 값인가 \(value)")
                if value == true {
                    textStatus.accept(!value)
                    outputText.accept(emptyMessage)
                } else {
                    outputText.accept(empty)
                }
            }
            .disposed(by: disposeBag)
        
        input.nextButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(textStatus) { _, value in
                print("textHiddenStatus: \(value)")
                return value
            }
            .bind { value in
                borderStatus.accept(value)
                if outputText.value == empty {
                    outputText.accept(modifyMessage)
                }
                if value == true {
                    pushStatus.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(textStatus: textStatus, pushStatus: pushStatus, outputText: outputText, borderStatus: borderStatus, sendText: sendText)
    }
    
}
