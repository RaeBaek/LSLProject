//
//  CommentEditViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentEditViewModel: ViewModelType {
 
    struct Input {
        let postID: BehaviorRelay<String>
        let textViewText: ControlProperty<String>
        let textViewBeginEditing: ControlEvent<Void>
        let textViewEndEditing: ControlEvent<Void>
        let postEditButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let currentData: PublishRelay<PostResponse>
        let textViewBeginEditing: PublishRelay<Void>
        let textViewEndEditing: PublishRelay<Bool>
        let postButtonStatus: BehaviorRelay<Bool>
        let postEditStatus: PublishRelay<Bool>
    }
    
    private let commentID: String
    private let repository: NetworkRepository
    private let disposeBag = DisposeBag()
    
    init(commentID: String, repository: NetworkRepository) {
        self.commentID = commentID
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let currentData = PublishRelay<PostResponse>()
        let textViewBeginEditing = PublishRelay<Void>()
        let textViewEndEditing = PublishRelay<Bool>()
        let postButtonStatus = BehaviorRelay<Bool>(value: false)
        let postEditStatus = PublishRelay<Bool>()
        
        input.postID
            .withUnretained(self)
            .flatMap { owner, id in
                owner.repository.requestAPost(id: id)
            }
            .bind { result in
                switch result {
                case .success(let data):
                    currentData.accept(data)
                case .failure(let error):
                    guard let aPostError = AllPostError(rawValue: error.rawValue) else {
                        print("게시글 공통 에러: \(error.message)")
                        return
                    }
                    print("게시글 커스텀 에러: \(aPostError.message)")
                }
            }
            .disposed(by: disposeBag)
        
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
                if value == "" {
                    return false
                } else {
                    return true
                }
            }
            .bind(to: postButtonStatus)
            .disposed(by: disposeBag)
        
        input.postEditButtonTap
            .withLatestFrom(input.textViewText) { _, text in
                return text
            }
            .withUnretained(self)
            .flatMap { owner, text in
                owner.repository.requestCommentEdit(id: input.postID.value, commentID: owner.commentID, content: text)
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    print("댓글 수정 완료!")
                    postEditStatus.accept(true)
                case .failure(let error):
                    guard let commentEditError = CommentEditError(rawValue: error.rawValue) else {
                        print("댓글 수정 공통 에러입니다. \(error.message)")
                        return
                    }
                    print("댓글 수정 커스텀 에러입니다. \(commentEditError.message)")
                    postEditStatus.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(currentData: currentData,
                      textViewBeginEditing: textViewBeginEditing,
                      textViewEndEditing: textViewEndEditing,
                      postButtonStatus: postButtonStatus,
                      postEditStatus: postEditStatus)
    }
    
}
