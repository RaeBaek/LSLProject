//
//  NetworkRepositoryType.swift
//  LSLProject
//
//  Created by 백래훈 on 11/21/23.
//

import Foundation
import RxSwift

protocol NetworkRepositoryType: AnyObject {
    
    func requestEmailValidation(email: String) -> Single<NetworkResult<EmailValidationResponse>>
    
    func requestSignUp(email: String?,
                       password: String?,
                       nick: String?,
                       phoneNum: String?,
                       birthDay: String?) -> Single<NetworkResult<SignUpResponse>>
    
    func requestLogin(email: String?,
                      password: String?) -> Single<NetworkResult<LoginResponse>>
    
    func requestAccessToken() -> Single<NetworkResult<AccessTokenResponse>>
    
    func requestWithdraw() -> Single<NetworkResult<WithdrawResponse>>
    
    func requestAllPost(next: String, limit: String, productID: String) -> Single<NetworkResult<PostResponses>>
    
    func requestPostAdd(title: String?, file: Data?, productID: String?) -> Single<NetworkResult<PostResponse>>
    
    func reqeustDownloadImage(path: String) -> Single<NetworkResult<DownloadImageResponse>>
    
}
