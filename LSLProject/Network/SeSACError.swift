//
//  SeSACError.swift
//  LSLProject
//
//  Created by 백래훈 on 11/20/23.
//

import Foundation

enum CommonError: Int, Error {
    case noSeSACKey = 420
    case overRequest = 429
    case abnomalURL = 444
    case serverError = 500
    
    var description: String {
        switch self {
        case .noSeSACKey:
            return "This service sesac_memolease only"
        case .overRequest:
            return "과호출입니다."
        case .abnomalURL:
            return "돌아가 여긴 자네가 올 곳이 아니야."
        case .serverError:
            return "ServerError "
        }
    }
}

enum SignUpError: Int, Error {
    case noValue = 400
    case usingValue = 409
    case severError = 500
    case unknowned = 999
    
    var desciption: String {
        switch self {
        case .noValue:
            return "필수 값을 채워주세요."
        case .usingValue:
            return "사용이 불가한 이메일입니다."
        case .severError:
            return "서버 에러입니다."
        case .unknowned:
            return "알 수 없는 에러입니다."
        }
    }
}
