//
//  PostDeleteViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/9/23.
//

import Foundation
import RxSwift
import RxCocoa

final class PostDeleteViewModel {
    
    private let repository: NetworkRepository
    
    private let diposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    struct PostInput {
        let deletePostButtonTap: ControlEvent<Void>
        let deletePostID: BehaviorRelay<String>
        
    }
    
    struct CommentInput {
        let deleteCommentButtonTap: ControlEvent<Void>
        let deletePostID: BehaviorRelay<String>
        let deleteCommentID: BehaviorRelay<String>
    }
    
    struct PostOuput {
        let deletePostStatus: PublishRelay<Bool>
    }
    
    struct CommentOutput {
        let deleteCommentStatus: PublishRelay<Bool>
    }
    
    func postTransform(input: PostInput) -> PostOuput {
        let deletePostStatus = PublishRelay<Bool>()
        
        let deletePostButtonTap = input.deletePostButtonTap
        let deletePostID = input.deletePostID
        
        deletePostButtonTap
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestPostDelete(id: deletePostID.value)
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    print("게시물 삭제 완료!")
                    deletePostStatus.accept(true)
                case .failure(let error):
                    guard let postDeleteError = PostDeleteError(rawValue: error.rawValue) else {
                        print("게시물 삭제 공통 에러입니다. \(error.message)")
                        deletePostStatus.accept(false)
                        return
                    }
                    print("게시물 삭제 커스텀 에러입니다. \(postDeleteError.message)")
                    deletePostStatus.accept(false)
                }
            })
            .disposed(by: diposeBag)
        
        return PostOuput(deletePostStatus: deletePostStatus)
        
    }
    
    func commentTransform(input: CommentInput) -> CommentOutput {
        let deleteCommentStatus = PublishRelay<Bool>()
        
        let deletePostButtonTap = input.deleteCommentButtonTap
        let deletePostID = input.deletePostID
        let deleteCommentID = input.deleteCommentID
        
        deletePostButtonTap
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestCommentDelete(id: deletePostID.value, commentID: deleteCommentID.value)
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    print("댓글 삭제 완료!")
                    deleteCommentStatus.accept(true)
                case .failure(let error):
                    guard let commentDeleteError = CommentDeleteError(rawValue: error.rawValue) else {
                        print("댓글 삭제 공통 에러입니다. \(error.message)")
                        deleteCommentStatus.accept(false)
                        return
                    }
                    print("댓글 삭제 커스텀 에러입니다. \(commentDeleteError.message)")
                    deleteCommentStatus.accept(false)
                }
            })
            .disposed(by: diposeBag)
        
        return CommentOutput(deleteCommentStatus: deleteCommentStatus)
    }
    
}
