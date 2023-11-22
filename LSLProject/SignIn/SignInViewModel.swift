//
//  SignInViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/22/23.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel {
    
    struct Input {
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let signInButtonClicked: ControlEvent<Void>
        let signUpButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let textStatus: PublishRelay<Bool>
        let borderStatus: PublishRelay<Bool>
        let outputText: PublishRelay<String>
        let loginStatus: PublishRelay<Bool>
        let signUpStatus: PublishRelay<Void>
    }
    
    private let repository: NetworkRepository
    private let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let textStatus = PublishRelay<Bool>()
        let borderStatus = PublishRelay<Bool>()
        let outputText = PublishRelay<String>()
        let statusCode = PublishRelay<Int>()
        let loginStatus = PublishRelay<Bool>()
        let signUpStatus = PublishRelay<Void>()
        
        input.emailText
            .distinctUntilChanged()
            .map { _ in
                return true
            }
            .bind(to: textStatus, borderStatus)
            .disposed(by: disposeBag)
        
        input.passwordText
            .distinctUntilChanged()
            .map { _ in
                return true
            }
            .bind(to: textStatus, borderStatus)
            .disposed(by: disposeBag)
        
        input.signInButtonClicked
            .withLatestFrom(input.emailText) { _, email in
                return email
            }
            .withLatestFrom(input.passwordText, resultSelector: { email, password in
                return (email, password)
            })
            .flatMap { value in
                self.repository.requestLogin(email: value.0, password: value.1)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    UserDefaultsManager.token = data.token
                    UserDefaultsManager.refreshToken = data.refreshToken
                    print("로그인 성공!")
                    print("Token: \(UserDefaultsManager.token)")
                    print("Refresh Token: \(UserDefaultsManager.refreshToken)")
                    
                    statusCode.accept(200)
                    
                case .failure(let error):
                    guard let loginError = LoginError(rawValue: error.rawValue) else {
                        print("=====", error.message)
                        print("-----", error.rawValue)
                        outputText.accept(error.message)
                        statusCode.accept(error.rawValue)
                        textStatus.accept(false)
                        borderStatus.accept(false)
                        return
                    }
                    outputText.accept(loginError.message)
                    statusCode.accept(loginError.rawValue)
                    textStatus.accept(false)
                    borderStatus.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        input.signUpButtonClicked
            .bind(to: signUpStatus)
            .disposed(by: disposeBag)
        
        statusCode
            .map { $0 == 200 }
            .filter { $0 }
            .bind(to: loginStatus)
            .disposed(by: disposeBag)
            
        return Output(textStatus: textStatus, borderStatus: borderStatus, outputText: outputText, loginStatus: loginStatus, signUpStatus: signUpStatus)
    }
    
}
