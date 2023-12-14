//
//  HeartViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class HeartViewModel: ViewModelType {
    
    let repository: NetworkRepository
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    struct Input {
        let refreshing: ControlEvent<Void>?
        let sendData: BehaviorRelay<Void>
    }
    
    struct Output {
        let heartPosts: PublishRelay<PostResponses>
        let refreshLoading: PublishRelay<Bool>
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let heartPosts = PublishRelay<PostResponses>()
        let refreshLoading = PublishRelay<Bool>()
        
        let sendData = input.sendData
        
        guard let refreshing = input.refreshing else {
            return Output(heartPosts: heartPosts,
                          refreshLoading: refreshLoading)
        }
        
        refreshing
            .bind { value in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    refreshLoading.accept(true)
                    sendData.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        sendData
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.repository.requestLikes()
            }
            .withUnretained(self)
            .bind { owner, response in
                switch response {
                case .success(let data):
                    heartPosts.accept(data)
                    
                case .failure(let error):
                    guard let likesError = LikesError(rawValue: error.rawValue) else {
                        print("내가 좋아요한 포스트 조회 공통 에러.. \(error.message)")
                        return
                    }
                    print("내가 좋아요한 포스트 조회 에러 \(likesError.message)")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(heartPosts: heartPosts, 
                      refreshLoading: refreshLoading)
    }
    
}
