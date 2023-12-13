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
        let sendData: BehaviorRelay<Void>
        let contentID: BehaviorRelay<String>
        let commentButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let commentButtonTap: PublishRelay<Void>
        let postResponse: PublishRelay<PostResponse>
    }
    
    let repository: NetworkRepository
    
    let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let commentButtonTap = PublishRelay<Void>()
        let postResponse = PublishRelay<PostResponse>()
            
        input.commentButtonTap
            .bind(to: commentButtonTap)
            .disposed(by: disposeBag)
        
        input.sendData
            .withLatestFrom(input.contentID) { _, id in
                return id
            }
            .withUnretained(self)
            .flatMap { owner, id in
                owner.repository.requestAPost(id: id)
            }
            .withUnretained(self)
            .subscribe { owner, result in
                switch result {
                case .success(let data):
                    print("해당 게시물 조회 성공!")
                    postResponse.accept(data)
                case .failure(let error):
                    guard let allPostError = AllPostError(rawValue: error.rawValue) else {
                        print("해당 게시물 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 해당 게시물 에러 \(allPostError.message)")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(commentButtonTap: commentButtonTap,
                      postResponse: postResponse)
    }
    
}
