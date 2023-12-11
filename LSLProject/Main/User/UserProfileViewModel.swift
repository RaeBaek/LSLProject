//
//  UserProfileViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/11/23.
//

import Foundation
import RxSwift
import RxCocoa

final class UserProfileViewModel: ViewModelType {
    
    let repository: NetworkRepository
    
    init(repository: NetworkRepository) {
        self.repository = repository
        
    }
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let sendData: BehaviorRelay<Data?>
        let userID: BehaviorRelay<String>
    }
    
    struct Output {
        let profile: PublishRelay<MyProfile>
        let userPosts: PublishRelay<PostResponses>
    }
    
    func transform(input: Input) -> Output {
        
        let profile = PublishRelay<MyProfile>()
        let userPosts = PublishRelay<PostResponses>()
        
        input.sendData
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestUserProfile(id: input.userID.value)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("다른 유저 프로필 조회 성공!")
                    profile.accept(data)
                case .failure(let error):
                    guard let userProfileError = UserProfileError(rawValue: error.rawValue) else {
                        print("다른 유저 프로필 조회 실패.. \(error.message)")
                        return
                    }
                    print("다른 유저 프로플 조회 에러 \(userProfileError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        input.sendData
            .withUnretained(self)
            .flatMap { owner, value in
                owner.repository.requestUserPosts(id: input.userID.value)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("다른 유저가 작성한 포스트 조회 성공! (다른 유저 프로필 화면)")
                    userPosts.accept(data)
                case .failure(let error):
                    guard let userPostsError = UserPostsError(rawValue: error.rawValue) else {
                        print("다른 유저가 작성한 포스트 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 유저별 작성한 포스트 조회 에러 \(userPostsError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        return Output(profile: profile,
                      userPosts: userPosts)
    }
    
}
