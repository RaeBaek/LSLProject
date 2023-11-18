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
        let outputText: PublishRelay<String>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let outputText = PublishRelay<String>()
        
        input.nextButtonClicked
            .withLatestFrom(input.inputText) { _, text in
                return text
            }
            .bind(to: outputText)
            .disposed(by: disposeBag)
        
        return Output(outputText: outputText)
    }
    
}
