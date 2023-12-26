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
    
    func requestAllPost(next: String,
                        limit: String,
                        productID: String) -> Single<NetworkResult<PostResponses>>
    
    func requestPostAdd(title: String?,
                        file: Data?,
                        productID: String?) -> Single<NetworkResult<PostResponse>>
    
    func requestPostEdit(id: String,
                         title: String?,
                         file: Data?,
                         productID: String?) -> Single<NetworkResult<PostResponse>>
    
    func requestPostDelete(id: String) -> Single<NetworkResult<PostDelete>>
    
    func requestImage(path: String) -> Single<NetworkResult<Data>>
    
    func requestMyProfile() -> Single<NetworkResult<MyProfile>>
    
    func requestUserProfile(id: String) -> Single<NetworkResult<MyProfile>>
    
    func requestUserPosts(id: String) -> Single<NetworkResult<PostResponses>>
    
    func requestCommentAdd(id: String, comment: String) -> Single<NetworkResult<Comment>>
    
    func requestCommentDelete(id: String, commentID: String) -> Single<NetworkResult<CommentDeleteResponse>>
    
    func requestProfileEdit(profile: Data?,
                            nick: String,
                            phoneNum: String?,
                            birthDay: String?) -> Single<NetworkResult<MyProfile>>
    
    func requestFollow(id: String) -> Single<NetworkResult<FollowResponse>>
    
    func requestUnFollow(id: String) -> Single<NetworkResult<FollowResponse>>
    
    func requestAPost(id: String) -> Single<NetworkResult<PostResponse>>
    
    func requestLike(id: String) -> Single<NetworkResult<LikeResponse>>
    
    func requestLikes() -> Single<NetworkResult<PostResponses>>
    
}
