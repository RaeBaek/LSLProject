//
//  LoginRepository.swift
//  LSLProject
//
//  Created by 백래훈 on 11/20/23.
//

import Foundation
import RxSwift

protocol NetworkRepositoryType: AnyObject {
    func requestEmailValidation(email: String) -> Single<NetworkResult<EmailValidationResponse>>
}

class LoginRepository: NetworkRepositoryType {
    func requestEmailValidation(email: String) -> Single<NetworkResult<EmailValidationResponse>> {
        APIManager.shared.request(target: .emailValidation(model: EmailValidation(email: email)))
    }
}
