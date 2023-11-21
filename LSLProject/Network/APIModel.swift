//
//  APIModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/15/23.
//

import Foundation

//MARK: - Encodable
struct SignUp: Encodable {
    let email: String?
    let password: String?
    let nick: String?
    let phoneNum: String?
    let birthDay: String?
}

struct EmailValidation: Encodable {
    let email: String
}

//MARK: - Decodable {
struct EmailValidationResponse: Decodable {
    let message: String
}

struct SignUpResponse: Decodable {
    let id: String
    let email: String
    let nick: String
    
    enum CodingKeys: String, CodingKey {
        case email, nick
        case id = "_id"
    }
}
