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
    
}
