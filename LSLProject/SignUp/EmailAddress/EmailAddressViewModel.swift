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
    }
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let textStatus = PublishRelay<Bool>()
        let pushStatus = PublishRelay<Bool>()
        let statusCode = PublishRelay<Int>()
        let outputText = PublishRelay<String>()
        let borderStatus = PublishRelay<Bool>()
        
        input.inputText
            .distinctUntilChanged()
            .map { _ in
                return true
            }
            .bind { value in
                borderStatus.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.nextButtonClicked
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.inputText) { _, text in
                print(text)
                return text
            }
            .flatMap {
                APIManager.shared.emailValidationAPI3(email: $0)
            }
            .subscribe(with: self, onNext: { owner, value in
                switch value {
                case .success():
                    statusCode.accept(200)
                    outputText.accept("사용 가능한 이메일입니다.")
                case .failure(let error):
                    statusCode.accept(error.rawValue)
                    outputText.accept(error.desciption)
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
        
        return Output(textStatus: textStatus, pushStatus: pushStatus, outputText: outputText, borderStatus: borderStatus)
    }
    
    func requestEmailValidationAPI(email: String, completionHandler: @escaping (EmailValidationResponse, Int) -> Void) {
        APIManager.shared.emailValidationAPI(email: email) { response, statusCode  in
            switch response {
            case .success(let success):
                dump(success)
                completionHandler(success, statusCode)
            case .failure(let failure):
                print("에러코드: \(failure.rawValue)")
                print("에러메시지: \(failure.desciption)")
            }
        }
    }
    
}
