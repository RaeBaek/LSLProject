//
//  HomeDetailViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeDetailViewModel: ViewModelType {
    
    struct Input {
        let commentButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let commentButtonTap: PublishRelay<Void>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let commentButtonTap = PublishRelay<Void>()
            
        input.commentButtonTap
            .bind(to: commentButtonTap)
            .disposed(by: disposeBag)
        
        return Output(commentButtonTap: commentButtonTap)
    }
}
