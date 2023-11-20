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

@frozen enum NetworkResult<T: Decodable> {
    case success(T)
    case failure(LoggableError)
}

protocol LoggableError: Error {
    var rawValue: Int { get }
    var message: String { get }
}

enum NetworkError: Int, LoggableError {
    case invalidData = 0
    case noValue = 400
    case checkAccount = 401
    case noAccessAuthority = 403
    case usingValue = 409
    case dbServerFailure = 410
    case expireAccessToken = 419
    case noSeSACKey = 420
    case overRequest = 429
    case abnomalURL = 444
    case noEditAuthority = 445
    case serverError = 500
    case unknowned = 999
    
    var message: String {
        switch self {
        case .noSeSACKey:
            return "This service sesac_memolease only"
        case .overRequest:
            return "과호출입니다."
        case .abnomalURL:
            return "돌아가 여긴 자네가 올 곳이 아니야."
        case .serverError:
            return "서버 에러입니다."
        case .unknowned:
            return "알 수 없는 에러입니다."
        default:
            return ""
        }
    }
}

protocol NetworkService {
    func request<T: Decodable>(target: SeSACAPI) -> Single<NetworkResult<T>>
}

final class APIManager: NetworkService {
    
    static let shared = APIManager()
    
    private init() { }
    
    private let provider = MoyaProvider<SeSACAPI>()
    
    func request<T: Decodable>(target: SeSACAPI) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { [weak self] (single) -> Disposable in
            guard let self else { return Disposables.create() }
            
            self.provider.request(target) { result in
                switch result {
                case .success(let response):
                    dump(response)
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
                    single(.success(.failure(networkError)))
                }
            }
            return Disposables.create()
        }
        .debug()
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
