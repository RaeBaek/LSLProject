//
//  NetworkRepositoryType.swift
//  LSLProject
//
//  Created by 백래훈 on 11/21/23.
//

import Foundation
import RxSwift
import Moya

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
    
    func requestImage(path: String) -> Single<NetworkResult<Data>>//Result<DownloadImageResponse, MoyaError>
    
    func requestMyProfile() -> Single<NetworkResult<MyProfile>>
    
    func requestUserPosts(id: String) -> Single<NetworkResult<PostResponses>>
    
    func requestCommentAdd(id: String, comment: String) -> Single<NetworkResult<Comment>>
    
}
