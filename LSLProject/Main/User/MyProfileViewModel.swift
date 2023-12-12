//
//  UserViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class MyProfileViewModel: ViewModelType {
    
    let myProfile = PublishRelay<MyProfile>()
    private let repository: NetworkRepository
    private let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    struct Input {
        let sendData: PublishRelay<Data>
    }
    
    struct Output {
        let userPosts: PublishRelay<PostResponses>
    }
    
    func transform(input: Input) -> Output {
        let userPosts = PublishRelay<PostResponses>()
        let id = BehaviorRelay(value: UserDefaultsManager.id)
        
        input.sendData
            .withLatestFrom(id)
            .withUnretained(self)
            .flatMapLatest { owner, id in
                return owner.repository.requestMyProfile()
            }
            .withUnretained(self)
            .bind { owner, response in
                switch response {
                case .success(let success):
                    owner.myProfile.accept(success)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        input.sendData
            .withLatestFrom(id)
            .withUnretained(self)
            .flatMapLatest { owner, id in
                return owner.repository.requestUserPosts(id: id)
            }
            .bind(with: self) { owner, response in
                switch response {
                case .success(let data):
                    print("내가 작성한 포스트 조회 성공! (내 프로필 화면)")
                    userPosts.accept(data)
                    
                case .failure(let error):
                    guard let userPostsError = UserPostsError(rawValue: error.rawValue) else {
                        print("내가 작성한 포스트 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 유저별 작성한 포스트 조회 에러 \(userPostsError.message)")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(userPosts: userPosts)
        
        // MARK: - 원본
//        input.sendData
////            .debug("sendData")
//            .withUnretained(self)
//            .flatMap { owner, _ in
//                print("~~~~~~~~ \(UserDefaultsManager.id)")
//                return owner.repository.requestUserPosts(id: UserDefaultsManager.id)
//            }
//            .subscribe(onNext: { value in
//                switch value {
//                case .success(let data):
//                    print("내가 작성한 포스트 조회 성공! (내 프로필 화면)")
//                    userPosts.accept(data)
//                    
//                case .failure(let error):
//                    guard let userPostsError = UserPostsError(rawValue: error.rawValue) else {
//                        print("내가 작성한 포스트 조회 실패.. \(error.message)")
//                        return
//                    }
//                    print("커스텀 유저별 작성한 포스트 조회 에러 \(userPostsError.message)")
//                }
//            })
//            .disposed(by: disposeBag)
        
    }
    
}
