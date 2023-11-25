//
//  MainHomeViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/22/23.
//

import Foundation
import RxSwift
import RxCocoa

final class MainHomeViewModel {
    
    struct Input {
        let withdraw: ControlEvent<Void>
    }
    
    struct Output {
        let check: PublishRelay<Bool>
    }
    
    let repository: NetworkRepository
    
    let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        let statusCode = BehaviorRelay<Int?>(value: nil)//PublishRelay<Int?>()
        let check = PublishRelay<Bool>()
        
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
        
        return Output(check: check)
    }
    
}
