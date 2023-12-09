//
//  MainHomeViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/22/23.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: ViewModelType {
    
    struct Input {
        let userID: BehaviorRelay<String>
        let allPost: BehaviorRelay<AllPost>
        let withdraw: ControlEvent<Void>
    }
    
    struct CellButtonInput {
        let creatorID: BehaviorRelay<String>
        let moreButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let items: PublishRelay<PostResponses>
        let check: PublishRelay<Bool>
    }
    
    struct CellButtonOutput {
        let postStatus: PublishRelay<Bool>
    }
    
    private let repository: NetworkRepository
    
    private let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        let statusCode = BehaviorRelay<Int?>(value: nil)//PublishRelay<Int?>()
        let check = PublishRelay<Bool>()
        let items = PublishRelay<PostResponses>()
        
        input.userID
            .withLatestFrom(input.allPost, resultSelector: { _, value in
                return value
            })
            .flatMap { value in
                self.repository.requestAllPost(next: value.next, limit: value.limit, productID: value.productID)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("포스트 조회 성공!!")
                    items.accept(data)
                case .failure(let error):
                    guard let allPostError = AllPostError(rawValue: error.rawValue) else {
                        print("포스트 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
        
        // 회원탈퇴에 관한 코드
        // 추후 리팩토링 예정
        statusCode
            .skip(1)
            .compactMap { $0 }
            .debug("withdraw")
            .bind { value in
                let error = [401, 403, 420, 429, 444, 500]
                
                if value == 200 {
                    print("회원 탈퇴가 정상적으로 수행되었습니다.")
                    check.accept(true)
                } else if value == 419 {
                    print("Access Token이 만료 되었습니다.(419)")
                    print("/refresh 라우터를 통해 토큰 갱신 필요")
//                    check.accept(true)
                } else if error.contains(value) {
//                    check.accept(true)
                    print("심각한 공통에러입니다. 확인해주세요! 401, 403, 420, 429, 444, 500")
                }
                
            }
            .disposed(by: disposeBag)
        
        let withdraw = input.withdraw
    
        withdraw
            .flatMap {
                self.repository.requestWithdraw()
                    .catch { error in
                        print("=========!!!!!= \(error)")
                        return Single.never()
                    }
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(_):
                    print("회원 탈퇴 완료!!!!!!!!!")
                    statusCode.accept(200)
                    UserDefaultsManager.token = "토큰 없음"
                    UserDefaultsManager.refreshToken = "리프레시 토큰 없음"
                    
                case .failure(let error):
                    print("회원 탈퇴 실패... \(error.message)")
                    statusCode.accept(error.rawValue)
                    
                }
            })
            .disposed(by: disposeBag)
        
        return Output(items: items, check: check)
    }
    
    func buttonTransform(input: CellButtonInput) -> CellButtonOutput {
        
        let postStatus = PublishRelay<Bool>()
        
        input.moreButtonTap
            .withLatestFrom(input.creatorID, resultSelector: { _, id in
                print("확인1 \(Date()), \(input.creatorID.value)")
                print("확인2 \(Date()), \(UserDefaultsManager.id)")
                
                if input.creatorID.value == UserDefaultsManager.id {
                    return true
                } else {
                    return false
                }
            })
            .debug("확인")
            .bind(to: postStatus)
            .disposed(by: disposeBag)
        
        
        
//            .flatMap { _ in
//                //여기서 유저별 작성한 API 말고 내 프로필 확인하면 되는디?
//                return self.repository.requestMyProfile()
//            }
//            .subscribe(onNext: { result in
//                switch result {
//                case .success(_):
//                    print("((((((((((((((((((((( \(input.creatorID.value)")
//                    if input.creatorID.value == UserDefaultsManager.id {
//                        postStatus.accept(true)
//                    } else {
//                        postStatus.accept(false)
//                    }
////                    postStatus.accept(data.posts.map { $0 }.contains(input.creatorID.value))
//                case .failure(let error):
//                    guard let userPostsError = UserPostsError(rawValue: error.rawValue) else {
//                        print("유저별 작성한 포스트 조회 실패.. \(error.message)")
//                        return
//                    }
//                    print("커스텀 유저별 작성한 포스트 조회 에러 \(userPostsError.message)")
//                }
//            })
//            .disposed(by: disposeBag)
        
        return CellButtonOutput(postStatus: postStatus)
    }
    
}
