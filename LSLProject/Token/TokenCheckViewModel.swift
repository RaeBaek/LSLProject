//
//  TokenViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/23/23.
//

import Foundation
import RxSwift
import RxCocoa

final class TokenCheckViewModel: ViewModelType {
    
    struct Input {
        let token: BehaviorRelay<String>
    }
    
    struct Output {
        let check: BehaviorRelay<Bool?>//PublishRelay<Bool>
    }
    
    private var repository: NetworkRepository
    
    private let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let outputCheck = BehaviorRelay<Bool?>(value: nil)//PublishRelay<Bool>()
        let statusCode = BehaviorRelay<Int?>(value: nil)//PublishRelay<Int>()//BehaviorRelay<Int?>(value: 0)
        
        print("=====", UserDefaultsManager.token)
        
        statusCode
            .skip(1)
            .compactMap { $0 }
            .debug("7")
            .bind { value in
                let error = [401, 403, 420, 429, 444, 500]
                
                if value == 200 {
                    print("토큰이 만료되어 갱신하였고 정상적으로 자동 로그인을 수행하였습니다.")
                    outputCheck.accept(false)
                } else if value == 409 {
                    print("액세스 토큰이 만료되지 않았습니다. 기존의 토큰을 유지합니다.")
                    outputCheck.accept(false)
                } else if value == 418 {
                    print("Refresh Token이 만료 되었습니다.(418)")
                    outputCheck.accept(true)
                    UserDefaultsManager.token = "토큰 없음"
                    UserDefaultsManager.refreshToken = "리프레시 토큰 없음"
                } else if error.contains(value) {
                    print("심각한 공통에러입니다. 확인해주세요! 401, 403 420, 429, 444, 500")
                    outputCheck.accept(true)
                    UserDefaultsManager.token = "토큰 없음"
                    UserDefaultsManager.refreshToken = "리프레시 토큰 없음"
                }
                
            }
            .disposed(by: disposeBag)
        
//        statusCode
//            .skip(1)
//            .map { $0 == 200 }
//            .filter { $0 }
//            .debug("4")
//            .bind { value in
//                print("토큰이 만료되어 갱신하였고 정상적으로 자동 로그인을 수행하였습니다.")
//                outputCheck.accept(!value)
//            }
//            .disposed(by: disposeBag)
        
//        let containToken = statusCode
//                                .map { $0 == 409 }
//                                .share()
        
//        statusCode
//            .skip(1)
//            .map { $0 == 409 }
//            .filter { $0 }
//            .debug("5")
//            .bind { value in
//                outputCheck.accept(!value)
//                print("액세스 토큰이 만료되지 않았습니다. 기존의 토큰을 유지합니다.")
//            }
//            .disposed(by: disposeBag)
//        
//        statusCode
//            .skip(1)
//            .map { $0 == 418 }
//            .filter { $0 }
//            .debug("6")
//            .bind { value in
//                outputCheck.accept(value)
//                print("Refresh Token이 만료 되었습니다.(418)")
//            }
//            .disposed(by: disposeBag)
//        
//        statusCode
//            .skip(1)
//            .map { [401, 403, 420, 429, 444, 500].contains($0) }
//            .filter { $0 }
//            .debug("6")
//            .bind { value in
//                outputCheck.accept(value)
//                print("심각한 공통에러입니다. 확인해주세요! 401, 403 420, 429, 444, 500")
//            }
//            .disposed(by: disposeBag)
            
        
        let hoon = input.token
                            .map { $0 == "토큰 없음" }
                            .debug("1")
                          //  .share()
        
        hoon
            .filter { $0 }
            .debug("2")
            .bind(to: outputCheck)
            .disposed(by: disposeBag)
        
        hoon
            .filter { !$0 }
            .observe(on: MainScheduler.asyncInstance)
            .debug("3")
            .flatMap { _ in
                self.repository.requestAccessToken()
                    .catch { error in
                        print("!!!!!!!", error)
                        return Single.never()
                    }
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("토큰 갱신완료!!")
                    UserDefaultsManager.token = data.token
                    statusCode.accept(200)
                    
                case .failure(let error):
                    guard let accessTokenError = AccessTokenError(rawValue: error.rawValue) else {
                        // 공통 에러일 때 420, 429, 444, 500
                        statusCode.accept(error.rawValue)
                        print("심각한 공통에러입니다. 확인해주세요! 420, 429, 444, 500")
                        print(error.rawValue)
                        print(error.message)
                        return
                    }
                    // 커스텀한 에러일 때 401, 403, 409, 418
                    print("커스텀 에러입니다.")
                    print("에러 코드 \(accessTokenError.rawValue)")
                    print("에러 메시지 \(accessTokenError.message)")
                    
                    statusCode.accept(accessTokenError.rawValue)
                    
                }
            })
            .disposed(by: disposeBag)

        return Output(check: outputCheck)
    }
    
}
