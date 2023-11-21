//
//  EmailAddressViewModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import Foundation
import RxSwift
import RxCocoa

class EmailAddressViewModel {
    
    struct Input {
        let inputText: ControlProperty<String>
        let nextButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let textStatus: PublishRelay<Bool>
        let pushStatus: PublishRelay<Bool>
        let outputText: PublishRelay<String>
        let borderStatus: PublishRelay<Bool>
        let sendText: PublishRelay<String>
    }
    
    private let repository: NetworkRepository
    private let disposeBag = DisposeBag()
    
    init(repository: NetworkRepository) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        
        let textStatus = PublishRelay<Bool>()
        let pushStatus = PublishRelay<Bool>()
        let statusCode = PublishRelay<Int>()
        let outputText = PublishRelay<String>()
        let borderStatus = PublishRelay<Bool>()
        let sendText = PublishRelay<String>()
        
        input.inputText
            .distinctUntilChanged()
            .map { _ in
                return true
            }
            .bind(to: borderStatus)
            .disposed(by: disposeBag)
        
        input.inputText
            .distinctUntilChanged()
            .bind(to: sendText)
            .disposed(by: disposeBag)
        
        input.nextButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .withLatestFrom(input.inputText) { _, text in
                print(text)
                return text
            }
            .flatMap { value in
                self.repository.requestEmailValidation(email: value)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success:
                    statusCode.accept(200)
                    outputText.accept("사용 가능한 이메일입니다.")
                case .failure(let error):
                    guard let emailValidationError = EmailValidationError(rawValue: error.rawValue) else {
                        print("=====", error.message)
                        print("-----", error.rawValue)
                        outputText.accept(error.message)
                        statusCode.accept(error.rawValue)
                        return
                    }
                    statusCode.accept(emailValidationError.rawValue)
                    outputText.accept(emailValidationError.message)
                }
            })
            .disposed(by: disposeBag)
        
        statusCode
            .map { $0 == 200 }
            .bind { value in
                textStatus.accept(value)
                if value == true {
                    pushStatus.accept(value)
                    print(value)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(textStatus: textStatus, pushStatus: pushStatus, outputText: outputText, borderStatus: borderStatus, sendText: sendText)
    }
    
//    private func requestEmailValidationAPI(email: String, completionHandler: @escaping (EmailValidationResponse, Int) -> Void) {
//        APIManager.shared.emailValidationAPI(email: email) { response, statusCode  in
//            switch response {
//            case .success(let success):
//                dump(success)
//                completionHandler(success, statusCode)
//            case .failure(let failure):
//                print("에러코드: \(failure.rawValue)")
//                print("에러메시지: \(failure.desciption)")
//            }
//        }
//    }
    
}
