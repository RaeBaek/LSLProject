//
//  UserViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import Foundation
import RxSwift
import RxCocoa

final class UserViewModel: ViewModelType {
    
    struct Input {
        let sendData: BehaviorRelay<Data?>
    }
    
    struct Output {
        let profile: PublishRelay<MyProfile>
        let userPosts: PublishRelay<PostResponses>
    }
    
    private let repository: NetworkRepository
    
    private let disposeBag = DisposeBag()
    
    init(reposity: NetworkRepository) {
        self.repository = reposity
    }
    
    func transform(input: Input) -> Output {
        
        let profile = PublishRelay<MyProfile>()
        let userPosts = PublishRelay<PostResponses>()
        
        input.sendData
            .flatMap { _ in
                self.repository.requestMyProfile()
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("내 프로필 조회 성공!")
                    profile.accept(data)
                case .failure(let error):
                    guard let allPostError = MyProfileError(rawValue: error.rawValue) else {
                        print("내 프로필 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        input.sendData
            .flatMap { value in
                self.repository.requestUserPosts(id: UserDefaultsManager.id)
            }
            .subscribe(onNext: { value in
                switch value {
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
            })
            .disposed(by: disposeBag)
        
        return Output(profile: profile, userPosts: userPosts)
    }
    
}
