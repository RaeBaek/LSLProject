//
//  SignInViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/22/23.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel: ViewModelType {
    
    struct Input {
        let token: BehaviorRelay<String>
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
                    print("로그인 성공!")
                    UserDefaultsManager.token = data.token
                    UserDefaultsManager.refreshToken = data.refreshToken
                    UserDefaultsManager.id = data.id
                    
                    input.token.accept(UserDefaultsManager.token)
                    
                case .failure(let error):
                    guard let loginError = LoginError(rawValue: error.rawValue) else {
                        print("=====", error.message)
                        print("-----", error.rawValue)
                        outputText.accept(error.message)
                        textStatus.accept(false)
                        borderStatus.accept(false)
                        return
                    }
                    outputText.accept(loginError.message)
                    textStatus.accept(false)
                    borderStatus.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        input.token
            .flatMap { _ in
                self.repository.requestMyProfile()
            }
            .subscribe { result in
                switch result {
                case .success(let data):
                    UserDefaultsManager.nickname = data.nick ?? "이 값이 보인다면 닉네임 기입에 문제.."
                    loginStatus.accept(true)
                case .failure(let error):
                    print("내 프로필 조회에 실패했습니다. (로그인 후 닉네임을 가져오는 경우!) \(error.message)")
                    loginStatus.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.signUpButtonClicked
            .bind(to: signUpStatus)
            .disposed(by: disposeBag)
            
        return Output(textStatus: textStatus, borderStatus: borderStatus, outputText: outputText, loginStatus: loginStatus, signUpStatus: signUpStatus)
    }
    
}
