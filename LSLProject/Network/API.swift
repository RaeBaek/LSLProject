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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signUp(let model):
            return .requestJSONEncodable(model)
        case .emailValidation(let model):
            return .requestJSONEncodable(model)
        }
    }
    
    var headers: [String : String]? {
        ["Content-Type": "application/json",
         "SesacKey": "Ikwn9wgcfM"]
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
}
