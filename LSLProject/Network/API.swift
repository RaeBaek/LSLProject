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
    case accessToken
    case withdraw
    
}

extension SeSACAPI: TargetType {
    var baseURL: URL {
        URL(string: "http://lslp.sesac.kr:27812/")! //27812: 테스트 서버, 27820: 본 서버
    }
    
    var path: String {
        switch self {
        case .signUp:
            return "join"
        case .emailValidation:
            return "validation/email"
        case .login:
            return "login"
        case .accessToken:
            return "refresh"
        case .withdraw:
            return "withdraw"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation, .login:
            return .post
        case .accessToken, .withdraw:
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
        case .accessToken, .withdraw:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        
        let key = APIKey.sesacKey
        let token = UserDefaultsManager.token
        let refreshToken = UserDefaultsManager.refreshToken
        
        switch self {
        case .signUp, .emailValidation, .login:
            return ["Content-Type": "application/json", "SesacKey": key]
        case .accessToken:
            return ["Authorization": token, "SesacKey": key, "Refresh": refreshToken]
        case .withdraw:
            return ["Authorization": token, "SesacKey": key]
        }
        
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
}
