//
//  TokenViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/23/23.
//

import Foundation
import RxSwift
import RxCocoa

class TokenCheckViewModel {
    
    struct Input {
        let check: Observable<Void>
    }
    
    struct Output {
        let token: PublishRelay<Bool>
    }
    
    let repository: NetworkRepository
    
    let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let token = PublishRelay<Bool>()
        let statusCode = PublishRelay<Int>()
        
        let check = input.check
                            .map { UserDefaultsManager.token == "토큰 없음" }
                            .share()
        
        check
            .filter { $0 }
            .bind(to: token)
            .disposed(by: disposeBag)
        
        check
            .filter { !$0 }
            .flatMap { [unowned self] _ in
                self.repository.requestAccessToken()
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    print("토큰 갱신완료!!")
                    UserDefaultsManager.token = data.token
                    UserDefaultsManager.refreshToken = data.refreshToken
                    statusCode.accept(200)
                    
                case .failure(let error):
                    guard let accessTokenError = AccessTokenError(rawValue: error.rawValue) else {
                        // 공통 에러일 때 420, 429, 444, 500
                        statusCode.accept(error.rawValue)
                        token.accept(false)
                        print("심각한 공통에러입니다. 확인해주세요!")
                        print(error.rawValue)
                        print(error.message)
                        return
                    }
                    // 커스텀한 에러일 때 401, 403, 409, 418
                    print("커스텀 에러입니다.")
                    print("에러 코드 \(accessTokenError.rawValue)")
                    print("에러 메시지 \(accessTokenError.message)")
                    
                    statusCode.accept(accessTokenError.rawValue)
//                    viewController.accept(SignInViewController())
                }
            })
            .disposed(by: disposeBag)

        statusCode
            .map { $0 == 200 }
            .filter { $0 }
            .bind { _ in
                print("토큰이 만료되어 갱신하였고 정상적으로 자동 로그인을 수행하였습니다.")
                token.accept(false)
            }
            .disposed(by: disposeBag)
        
        let containToken = statusCode
                                .map { $0 == 409 }
                                .share()
        
        containToken
            .filter { $0 }
            .bind { _ in
                token.accept(false)
                print("액세스 토큰이 만료되지 않았습니다. 기존의 토큰을 유지합니다.")
            }
            .disposed(by: disposeBag)
        
        containToken
            .filter { !$0 }
            .bind { _ in
                token.accept(true)
                print("AccessToken API 오류입니다. (401, 403, 418)")
            }
            .disposed(by: disposeBag)
        
        return Output(token: token)
    }
    
}
