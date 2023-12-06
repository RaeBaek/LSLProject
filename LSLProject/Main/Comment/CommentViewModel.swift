//
//  CommentViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/6/23.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel: ViewModelType {
    
    struct Input {
        let textViewText: ControlProperty<String>
        let textViewBeginEditing: ControlEvent<Void>
        let textViewEndEditing: ControlEvent<Void>
    }
    
    struct Output {
        let textViewBeginEditing: PublishRelay<Void>
        let textViewEndEditing: PublishRelay<Bool>
        let postButtonStatus: BehaviorRelay<Bool>
    }
    
    private let disposeBag = DisposeBag()
    
    let startMessage = "@@@@님에게 답글 남기기..."
    
    func transform(input: Input) -> Output {
        
        let textViewBeginEditing = PublishRelay<Void>()
        let textViewEndEditing = PublishRelay<Bool>()
        let postButtonStatus = BehaviorRelay<Bool>(value: false)
        
        input.textViewBeginEditing
            .bind(to: textViewBeginEditing)
            .disposed(by: disposeBag)
        
        input.textViewEndEditing
            .withLatestFrom(input.textViewText) { _, text in
                return text.isEmpty
            }
            .bind(to: textViewEndEditing)
            .disposed(by: disposeBag)
        
        input.textViewText
            .withUnretained(self)
            .map { owner, value in
                if value == "" || value == owner.startMessage {
                    return false
                } else {
                    return true
                }
            }
            .bind(to: postButtonStatus)
            .disposed(by: disposeBag)
        
        return Output(textViewBeginEditing: textViewBeginEditing,
                      textViewEndEditing: textViewEndEditing,
                      postButtonStatus: postButtonStatus)
    }
    
}

