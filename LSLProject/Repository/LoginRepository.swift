//
//  NetworkRepository.swift
//  LSLProject
//
//  Created by 백래훈 on 11/20/23.
//

import Foundation
import RxSwift

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
    
    
}
