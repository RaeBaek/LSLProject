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
    case exporeRefreshToken = 418
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

enum AccessTokenError: Int, LoggableError {
    case inValidAccessToken = 401
    case noAuthority = 403
    case expireAccessToken = 409
    case exporeRefreshToken = 418
    
    var message: String {
        switch self {
        case .inValidAccessToken:
            return "인증할 수 없는 Access Token입니다."
        case .noAuthority:
            return "Forbidden"
        case .expireAccessToken:
            return "Access Token이 만료되지 않았습니다."
        case .exporeRefreshToken:
            return "Refresh Token이 만료되었습니다."
        }
    }
}

enum WithdrawError: Int, LoggableError {
    case inValidAccessToken = 401
    case noAuthority = 403
    case expireAccessToken = 418
    
    var message: String {
        switch self {
        case .inValidAccessToken:
            return "인증할 수 없는 Access Token입니다."
        case .noAuthority:
            return "Forbidden"
        case .expireAccessToken:
            return "Access Token이 만료되었습니다."
        }
    }
}

enum AllPostError: Int, LoggableError {
    case invalidRequest = 400
    case inValidAccessToken = 401
    case noAuthority = 403
    case expireAccessToken = 419
    
    var message: String {
        switch self {
        case .invalidRequest:
            return "잘못된 요청입니다. 확인해주세요."
        case .inValidAccessToken:
            return "유효하지 않은 Access Token으로 요청하였습니다."
        case .noAuthority:
            return "Forbidden"
        case .expireAccessToken:
            return "Access Token이 만료되었습니다."
        }
    }
}

enum PostAddError: Int, LoggableError {
    case inValidRequest = 400
    case inValidAccessToken = 401
    case noAuthority = 403
    case dbServerError = 410
    case expireAccessToken = 419
    
    var message: String {
        switch self {
        case .inValidRequest:
            return "파일의 제한 사항과 맞지 않습니다."
        case .inValidAccessToken:
            return "유효하지 않은 Access Token으로 요청하였습니다."
        case .noAuthority:
            return "Forbidden"
        case .dbServerError:
            return "DB 서버 장애로 게시글이 저장되지 않았을 때 입니다. 다시 시도해주세요."
        case .expireAccessToken:
            return "Access Token이 만료되었습니다."
        }
        
    }
}
