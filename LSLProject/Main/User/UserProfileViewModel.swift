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
    
    let myProfile = PublishRelay<MyProfile>()
    let userProfile = PublishRelay<MyProfile>()
    let myFollowStatus = PublishRelay<Bool>()
    let userFollowStatus = PublishRelay<Bool>()
    
    let userID = PublishRelay<String>()
    
    let repository: NetworkRepository
    let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
        
    }
    
    struct Input {
        let sendData: PublishRelay<Data>
        let userID: BehaviorRelay<String>
    }
    
    struct Output {
        let userPosts: PublishRelay<PostResponses>
    }
    
    func transform(input: Input) -> Output {
        
        let userPosts = PublishRelay<PostResponses>()
        let userID = input.userID
        
        input.sendData
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.repository.requestMyProfile()
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, value in
                switch value {
                case .success(let data):
                    print("내 프로필 조회 성공!")
                    owner.myProfile.accept(data)
                   
                case .failure(let error):
                    guard let myProfileError = MyProfileError(rawValue: error.rawValue) else {
                        print("내 프로필 조회 실패.. \(error.message)")
                        return
                    }
                    print("내 프로필 조회 에러 \(myProfileError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        myProfile
            .bind(with: self) { owner, value in
                if value.following.map({ $0.id }).contains(userID.value) {
                    owner.myFollowStatus.accept(true)
                } else {
                    owner.myFollowStatus.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.sendData
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.userID.accept(userID.value)
                return owner.repository.requestUserProfile(id: userID.value)
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, value in
                switch value {
                case .success(let data):
                    print("다른 유저 프로필 조회 성공!")
                    owner.userProfile.accept(data)
                    
                case .failure(let error):
                    guard let userProfileError = UserProfileError(rawValue: error.rawValue) else {
                        print("다른 유저 프로필 조회 실패.. \(error.message)")
                        return
                    }
                    print("다른 유저 프로플 조회 에러 \(userProfileError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        userProfile
            .bind(with: self) { owner, value in
                if value.following.map({ $0.id }).contains(UserDefaultsManager.id) {
                    owner.userFollowStatus.accept(true)
                } else {
                    owner.userFollowStatus.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.sendData
            .withUnretained(self)
            .flatMap { owner, value in
                owner.repository.requestUserPosts(id: userID.value)
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
        
        return Output(userPosts: userPosts)
    }
    
}
