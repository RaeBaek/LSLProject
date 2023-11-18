//
//  APIManager.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

enum EmailValidationError: Int, Error, LocalizedError {
    case noValue = 400
    case usingValue = 409
    case severError = 500
    case unknowned = 999
    
    var desciption: String {
        switch self {
        case .noValue:
            return "필수 값을 채워주세요."
        case .usingValue:
            return "이미 누가 사용하고 있는 이메일입니다."
        case .severError:
            return "서버 에러입니다."
        case .unknowned:
            return "알 수 없는 에러입니다."
        }
    }
}

final class APIManager {
    
    static let shared = APIManager()
    
    private init() { }
    
    private let provider = MoyaProvider<SeSACAPI>()
    
    func emailValidationAPI3(email: String) -> Single<Result<Void, EmailValidationError>> {
        return Single<Result<Void, EmailValidationError>>.create { [weak self] single in
            
            guard let self else { return Disposables.create() }
            
            provider.request(.emailValidation(model: EmailValidation(email: email))) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200...299:
                        single(.success(.success(())))
                    case 400:
                        single(.success(.failure(.noValue)))
                    case 409:
                        single(.success(.failure(.usingValue)))
                    case 500:
                        single(.success(.failure(.severError)))
                    default:
                        single(.success(.failure(.unknowned)))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
        .debug()
    }
    
    func emailValidationAPI2(email: String) -> Observable<Result<Void, EmailValidationError>> {
        return Observable<Result<Void, EmailValidationError>>.create { [weak self] observer in
            
            guard let self else { return Disposables.create() }
            
            provider.request(.emailValidation(model: EmailValidation(email: email))) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200...299:
                        observer.onNext(.success(()))
                        observer.onCompleted()
                    case 400:
                        observer.onNext(.failure(.noValue))
                        observer.onCompleted()
                    case 409:
                        observer.onNext(.failure(.usingValue))
                        observer.onCompleted()
                    case 500:
                        observer.onNext(.failure(.severError))
                        return observer.onCompleted()
                    default:
                        observer.onNext(.failure(.unknowned))
                        observer.onCompleted()
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
        .debug()
    }
    
//    func statusCode(code: Int) -> Observable<Result<EmailValidationResponse, EmailValidationError>> {
//        
//    }
    
    func emailValidationAPI(email: String, completionHandler: @escaping (Result<EmailValidationResponse, EmailValidationError>, Int) -> Void) {
        
        let data = EmailValidation(email: email)
        
        provider.request(.emailValidation(model: data)) { result in
            
            switch result {
            case .success(let value):
                do {
                    print("Success: \(value.statusCode)")
                    let result = try JSONDecoder().decode(EmailValidationResponse.self, from: value.data)
                    completionHandler(.success(result), value.statusCode)
                } catch {
                    print("Error: \(value.statusCode)")
                }
                
                print("Result: \(result)")
                
            case .failure(let error):
                guard let error = EmailValidationError(rawValue: error.errorCode) else { return }
                print("Error: \(error)")
                completionHandler(.failure(error), error.rawValue)
            }
        }
    }
    
}

