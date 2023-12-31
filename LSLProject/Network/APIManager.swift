//
//  APIManager.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import Moya
import Alamofire
import RxSwift
import RxCocoa

@frozen enum NetworkResult<T: Decodable> {
    case success(T)
    case failure(LoggableError)
}

protocol NetworkService {
    func request<T: Decodable>(target: SeSACAPI) -> Single<NetworkResult<T>>
}

final class APIManager: NetworkService {
    
    static let shared = APIManager()
    
    private init() { }
    
    private let provider = MoyaProvider<SeSACAPI>(session: Moya.Session(interceptor: SeSACRequestInterceptor.shared))
    
    func request<T: Decodable>(target: SeSACAPI) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { [weak self] (single) -> Disposable in
            guard let self else { return Disposables.create() }

            self.provider.request(target) { result in
                switch result {
                case .success(let response):
                    dump(response)
                    
                    // T의 타입이 Data 타입인지 확인
                    if T.Type.self == Data.Type.self {
                        single(.success(.success(response.data as! T)))
                        return
                    } else {
                        print("??????", T.Type.self)
                    }
                    
                    guard let data = try? response.map(T.self) else {
                        single(.success(.failure(NetworkError.invalidData)))
                        return
                    }
                    single(.success(.success(data)))
                    
                case .failure(let error):
                    guard let statusCode = error.response?.statusCode,
                          let networkError = NetworkError(rawValue: statusCode) else {
                        single(.success(.failure(NetworkError.serverError)))
                        return
                    }
                    print(statusCode)
                    dump(error)
                    single(.success(.failure(networkError)))
                }
            }
            return Disposables.create()
        }
        .debug("request")
        
    }
    
    
//    func emailValidationAPI(email: String) -> Single<Result<Void, EmailValidationError>> {
//        return Single<Result<Void, EmailValidationError>>.create { [weak self] single in
//            
//            guard let self else { return Disposables.create() }
//            
//            self.provider.request(.emailValidation(model: EmailValidation(email: email))) { result in
//                switch result {
//                case .success(let value):
//                    switch value.statusCode {
//                    case 200...299:
//                        single(.success(.success(())))
//                    case 400:
//                        single(.success(.failure(.noValue)))
//                    case 409:
//                        single(.success(.failure(.usingValue)))
//                    case 500:
//                        single(.success(.failure(.severError)))
//                    default:
//                        single(.success(.failure(.unknowned)))
//                    }
//                case .failure(let error):
//                    single(.failure(error))
//                }
//            }
//            
//            return Disposables.create()
//        }
//        .debug()
//    }

}
