//
//  PostDeleteViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/9/23.
//

import Foundation
import RxSwift
import RxCocoa

final class PostDeleteViewModel: ViewModelType {
    
    private let repository: NetworkRepository
    
    private let diposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    struct Input {
        let deleteButtonTap: ControlEvent<Void>
        let deletePostID: BehaviorRelay<String>
    }
    
    struct Output {
        let deleteStatus: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let deleteStatus = PublishRelay<Bool>()
        
        let deleteButtonTap = input.deleteButtonTap
        let deletePostID = input.deletePostID
        
        deleteButtonTap
            .withUnretained(self)
            .flatMap { owner, _ in
                print("!!!!!!!!!!!!!!!!!", deletePostID.value)
                return owner.repository.requestPostDelete(id: deletePostID.value)
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    print("게시물 삭제 완료!")
                    deleteStatus.accept(true)
                case .failure(let error):
                    guard let postDeleteError = PostDeleteError(rawValue: error.rawValue) else {
                        print("게시물 삭제 공통 에러입니다. \(error.message)")
                        deleteStatus.accept(false)
                        return
                    }
                    print("게시물 삭제 커스텀 에러입니다. \(postDeleteError.message)")
                    deleteStatus.accept(false)
                }
            })
            .disposed(by: diposeBag)
        
        return Output(deleteStatus: deleteStatus)
        
    }
    
}
