//
//  SeSACError.swift
//  LSLProject
//
//  Created by 백래훈 on 11/20/23.
//

import Foundation

protocol LoggableError: Error {
    var rawValue: Int { get }
    var message: String { get }
}

enum NetworkError: Int, LoggableError {
    case invalidData = 0
    case noValue = 400
    case checkAccount = 401
    case noAccessAuthority = 403
    case usingValue = 409
    case dbServerFailure = 410
    case expireAccessToken = 419
    case noSeSACKey = 420
    case overRequest = 429
    case abnomalURL = 444
    case noEditAuthority = 445
    case serverError = 500
    case unknowned = 999
    
    var message: String {
        switch self {
        case .noSeSACKey:
            return "This service sesac_memolease only"
        case .overRequest:
            return "과호출입니다."
        case .abnomalURL:
            return "돌아가 여긴 자네가 올 곳이 아니야."
        case .serverError:
            return "서버 에러입니다."
        case .unknowned:
            return "알 수 없는 에러입니다."
        default:
            return ""
        }
    }
}

enum EmailValidationError: Int, LoggableError {
    
    case noValue = 400
    case usingValue = 409
    
    var message: String {
        switch self {
        case .usingValue:
            return "사용이 불가한 이메일입니다."
        case .noValue:
            return "필수 값을 채워주세요."
        }
    }
}

enum SignUpError: Int, LoggableError {
    case noValue = 400
    case usingValue = 409
    
    var message: String {
        switch self {
        case .noValue:
            return "필수 값을 채워주세요."
        case .usingValue:
            return "이미 가입한 사용자입니다."
        }
    }
}

enum LoginError: Int, LoggableError {
    case noValue = 400
    case checkAccount = 401
    
    var message: String {
        switch self {
        case .noValue:
            return "필수 값을 채워주세요."
        case .checkAccount:
            return "계정을 확인해주세요."
        }
    }
}
