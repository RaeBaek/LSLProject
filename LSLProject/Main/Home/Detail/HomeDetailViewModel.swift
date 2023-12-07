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
        let sendData: BehaviorRelay<Data?>
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
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestAllPost(next: "0", limit: "10", productID: "hihi")}
            .withLatestFrom(input.contentID) { result, id in
                return (result, id)
            }
            .subscribe { result, id in
                switch result {
                case .success(let data):
                    for i in 0..<data.data.count {
                        if data.data[i].id == id {
                            postResponse.accept(data.data[i])
                        } else {
                            print("일치하는 데이터가 없습니다. 요청을 확인해주세요.")
                        }
                    }
                case .failure(let error):
                    guard let allPostError = AllPostError(rawValue: error.rawValue) else {
                        print("포스트 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(commentButtonTap: commentButtonTap,
                      postResponse: postResponse)
    }
}
