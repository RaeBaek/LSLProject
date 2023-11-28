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

struct Login: Encodable {
    let email: String?
    let password: String?
}

struct PostAdd: Encodable {
    let title: String?
    let file: Data? // 확장자 제한: jpg, png, jpeg, gif, pdf - 용량제한 10MB/파일 당 - 최대 파일 개수: 5개
    let productID: String? // Threads
//    let content: String?
//    let content1: String? // 게시글의 comment
//    let content2: String?
//    let content3: String?
//    let content4: String?
//    let content5: String?
    
    enum CodingKeys: String, CodingKey {
        case title, file
//        content, content1, content2, content3, content4, content5
        case productID = "product_id"
    }
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

struct LoginResponse: Decodable {
    let token: String
    let refreshToken: String
}

struct AccessTokenResponse: Decodable {
    let token: String
}

struct WithdrawResponse: Decodable {
    let id: String
    let email: String
    let nick: String
    
    enum CodingKeys: String, CodingKey {
        case email, nick
        case id = "_id"
    }
}

struct PostResponse: Decodable {
    let likes: [String]
    let image: [String]
    let hashTags, comments: [String]
    let id: String
    let creator: Creator
    let time, title: String
    let content, content1, content2, content3, content4, content5: String?
    let productID: String

    enum CodingKeys: String, CodingKey {
        case likes, image, hashTags, comments
        case id = "_id"
        case creator, time, title, content, content1, content2, content3, content4, content5
        case productID = "product_id"
    }
}

// MARK: - Creator
struct Creator: Decodable {
    let id, nick: String
    let profile: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nick, profile
    }
}
