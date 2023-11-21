//
//  NicknameViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/16/23.
//

import Foundation
import RxSwift
import RxCocoa

class NicknameViewModel {
    
    struct Input {
        let inputText: ControlProperty<String>
        let nextButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let sendText : PublishRelay<String>
        let textStatus : PublishRelay<Bool>
        let borderStatus : PublishRelay<Bool>
        let pushStatus : PublishRelay<Bool>
        let outputText : PublishRelay<String>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let sendText = PublishRelay<String>()
        let textStatus = PublishRelay<Bool>()
        let borderStatus = PublishRelay<Bool>()
        let pushStatus = PublishRelay<Bool>()
        let outputText = PublishRelay<String>()
        
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
        
//        input.inputText
//            .map { $0 == "" }
//            .bind { value in
//                print("빈 값인가 \(value)")
//                if value == true {
//                    textStatus.accept(!value)
//                    outputText.accept("필수 값을 채워주세요.")
//                }
//            }
//            .disposed(by: disposeBag)
        
        input.nextButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.inputText) { _, value in
                print("textHiddenStatus: \(value)")
                return value
            }
            .map { $0 == "" }
            .bind { value in
                textStatus.accept(!value)
                borderStatus.accept(!value)
                outputText.accept("닉네임은 비워둘 수 없습니다.")
                if value == false {
                    pushStatus.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(sendText: sendText, textStatus: textStatus, borderStatus: borderStatus, pushStatus: pushStatus, outputText: outputText)
    }
    
}
