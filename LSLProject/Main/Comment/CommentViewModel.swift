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
        let postButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let textViewBeginEditing: PublishRelay<Void>
        let textViewEndEditing: PublishRelay<Bool>
        let postButtonStatus: BehaviorRelay<Bool>
        let postAddStatus: PublishRelay<Bool>
    }
    
    private let post: PostResponse
    
    private let repository: NetworkRepository
    
    private let disposeBag = DisposeBag()
    
    init(post: PostResponse, repository: NetworkRepository) {
        self.post = post
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let textViewBeginEditing = PublishRelay<Void>()
        let textViewEndEditing = PublishRelay<Bool>()
        let postButtonStatus = BehaviorRelay<Bool>(value: false)
        let postAddStatus = PublishRelay<Bool>()
        
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
                if value == "" || value == StartMessage.comment.placeholder {
                    return false
                } else {
                    return true
                }
            }
            .bind(to: postButtonStatus)
            .disposed(by: disposeBag)
        
        input.postButtonTap
            .withLatestFrom(input.textViewText, resultSelector: { _, text in
                return text
            })
            .withUnretained(self)
            .flatMap { owner, text in
                owner.repository.requestCommentAdd(id: owner.post.id, comment: text)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(_):
                    print("댓글 작성 완료!")
                    postAddStatus.accept(true)
                case .failure(let error):
                    guard let commentAddError = CommentAddError(rawValue: error.rawValue) else {
                        print("댓글 작성 공통 에러입니다. \(error.message)")
                        return
                    }
                    print("댓글 작성 커스텀 에러입니다. \(commentAddError.message)")
                    postAddStatus.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(textViewBeginEditing: textViewBeginEditing,
                      textViewEndEditing: textViewEndEditing,
                      postButtonStatus: postButtonStatus, postAddStatus: postAddStatus)
    }
    
}

