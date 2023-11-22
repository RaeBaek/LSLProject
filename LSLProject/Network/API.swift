//
//  API.swift
//  LSLProject
//
//  Created by 백래훈 on 11/15/23.
//

import Foundation
import Moya

enum SeSACAPI {
    case signUp(model: SignUp)
    case emailValidation(model: EmailValidation)
    case login(model: Login)
    case AccessToken
    
}

extension SeSACAPI: TargetType {
    var baseURL: URL {
        URL(string: "http://lslp.sesac.kr:27820/")!
    }
    
    var path: String {
        switch self {
        case .signUp:
            return "join"
        case .emailValidation:
            return "validation/email"
        case .login:
            return "login"
        case .AccessToken:
            return "refresh"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation, .login:
            return .post
        case .AccessToken:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signUp(let model):
            return .requestJSONEncodable(model)
        case .emailValidation(let model):
            return .requestJSONEncodable(model)
        case .login(let model):
            return .requestJSONEncodable(model)
        case .AccessToken:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        
        let key = APIKey.sesacKey
        let token = APIKey.accessToken
        let refreshToken = APIKey.refreshToken
        
        switch self {
        case .signUp, .emailValidation, .login:
            return ["Content-Type": "application/json", "SesacKey": key]
        case .AccessToken:
            return ["Authorization": token, "SesacKey": key, "Refresh": refreshToken]
        }
        
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
}
