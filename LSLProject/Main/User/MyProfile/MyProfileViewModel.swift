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
        let refreshing: ControlEvent<Void>?
        let sendData: BehaviorRelay<Void>
    }
    
    struct Output {
        let userPosts: PublishRelay<PostResponses>
        let refreshLoading: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let userPosts = PublishRelay<PostResponses>()
        let id = BehaviorRelay(value: UserDefaultsManager.id)
        let refreshLoading = PublishRelay<Bool>()
        
        let sendData = input.sendData
        
        guard let refreshing = input.refreshing else {
            return Output(userPosts: userPosts,
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
            .withLatestFrom(id)
            .withUnretained(self)
            .flatMapLatest { owner, id in
                return owner.repository.requestMyProfile()
            }
            .withUnretained(self)
            .debug("'myProfile'")
            .bind { owner, response in
                switch response {
                case .success(let data):
                    owner.myProfile.accept(data)
                    
                case .failure(let error):
                    guard let myProfileError = MyProfileError(rawValue: error.rawValue) else {
                        print("내 프로필 조회 공통 에러.. \(error.message)")
                        return
                    }
                    print("커스텀 내 프로필 조회 에러 \(myProfileError.message)")
                }
            }
            .disposed(by: disposeBag)
        
        sendData
            .withLatestFrom(id)
            .withUnretained(self)
            .flatMapLatest { owner, id in
                owner.repository.requestUserPosts(id: id)
            }
            .debug("'myPost'")
            .bind(with: self) { owner, response in
                switch response {
                case .success(let data):
                    print("내가 작성한 포스트 조회 성공! (내 프로필 화면)")
                    userPosts.accept(data)
                    
                case .failure(let error):
                    guard let userPostsError = UserPostsError(rawValue: error.rawValue) else {
                        print("내가 작성한 포스트 공통 에러.. \(error.message)")
                        return
                    }
                    print("커스텀 유저별 작성한 포스트 조회 에러 \(userPostsError.message)")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(userPosts: userPosts,
                      refreshLoading: refreshLoading)
        
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
