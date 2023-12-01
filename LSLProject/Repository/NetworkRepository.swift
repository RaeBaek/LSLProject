//
//  NetworkRepository.swift
//  LSLProject
//
//  Created by 백래훈 on 11/20/23.
//

import Foundation
import RxSwift
import Moya

class NetworkRepository: NetworkRepositoryType {

    func requestEmailValidation(email: String) -> Single<NetworkResult<EmailValidationResponse>> {
        APIManager.shared.request(target: .emailValidation(model: EmailValidation(email: email)))
        
    }
    
    func requestSignUp(email: String?,
                       password: String?,
                       nick: String?,
                       phoneNum: String?,
                       birthDay: String?) -> Single<NetworkResult<SignUpResponse>> {
        APIManager.shared.request(target: .signUp(model: SignUp(email: email,
                                                                password: password,
                                                                nick: nick,
                                                                phoneNum: phoneNum,
                                                                birthDay: birthDay)))
        
    }
    
    func requestLogin(email: String?, password: String?) -> Single<NetworkResult<LoginResponse>> {
        APIManager.shared.request(target: .login(model: Login(email: email,
                                                              password: password)))
    }
    
    func requestAccessToken() -> Single<NetworkResult<AccessTokenResponse>> {
        APIManager.shared.request(target: .accessToken)
    }
    
    func requestWithdraw() -> Single<NetworkResult<WithdrawResponse>> {
        APIManager.shared.request(target: .withdraw)
    }
    
    func requestAllPost(next: String, limit: String, productID: String) -> Single<NetworkResult<PostResponses>> {
        APIManager.shared.request(target: .allPost(model: AllPost(next: next, limit: limit, productID: productID)))
    }
    
    func requestPostAdd(title: String?, file: Data?, productID: String?) -> Single<NetworkResult<PostResponse>> {
        APIManager.shared.request(target: .postAdd(model: PostAdd(title: title, file: file, productID: productID)))
    }
    
    func reqeustImage(path: String) -> Single<NetworkResult<Data>> {
        APIManager.shared.request(target: .downloadImage(model: DownloadImage(path: path)))
    }
    
}
