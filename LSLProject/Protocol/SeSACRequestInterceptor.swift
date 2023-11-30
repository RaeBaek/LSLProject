//
//  SeSACRequestInterceptor.swift
//  LSLProject
//
//  Created by 백래훈 on 11/25/23.
//

import Foundation
import Alamofire
import RxSwift

final class SeSACRequestInterceptor: RequestInterceptor {
    
    static let shared = SeSACRequestInterceptor()
    
    private init() { }
    
    let repository = NetworkRepository()
    
    let disposeBag = DisposeBag()
    
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        guard urlRequest.url?.absoluteString.hasPrefix(APIKey.sesacURL) == true else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        
        urlRequest.setValue(UserDefaultsManager.token, forHTTPHeaderField: "Authorization")
        urlRequest.setValue(UserDefaultsManager.refreshToken, forHTTPHeaderField: "Refresh")
        urlRequest.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
        
        print("adator 적용 \(urlRequest.headers)")
        completion(.success(urlRequest))
        
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        print("============", response.statusCode)
        
        let task = Observable.just(())
        
        task
//            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
//            .observe(on: CurrentThreadScheduler.instance)
            .observe(on: SerialDispatchQueueScheduler.init(qos: .background))
            .do {
                print("2hhh", Thread.isMainThread)
            }
            .flatMap { _ in
                self.repository.requestAccessToken()//requestRetryAccessToken()
            }
            .do {
                print("3hhh", Thread.isMainThread)
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(let data):
                    print(UserDefaultsManager.token)
                    UserDefaultsManager.token = data.token
                    completion(.retry)
                case .failure(let error):
                    completion(.doNotRetryWithError(error))
                }
            })
            .disposed(by: disposeBag)
        
    }
    
}
