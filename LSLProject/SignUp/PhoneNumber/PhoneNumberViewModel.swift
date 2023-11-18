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
        let sendText: PublishRelay<String?>
    }
    
    func transform(input: Input) -> Output {
        
        let sendText = PublishRelay<String?>()
        
        input.nextButtonClicked
            .withLatestFrom(input.inputText) { _, text in
                return text
            }
            .bind(to: sendText)
            .disposed(by: disposeBag)
        
        input.skipButtonClicked
            .bind { _ in
                sendText.accept(nil)
            }
            .disposed(by: disposeBag)
        
        return Output(sendText: sendText)
    }
    
}
