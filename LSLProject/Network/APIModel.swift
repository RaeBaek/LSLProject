//
//  APIModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/15/23.
//

import Foundation
import UIKit

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

struct AllPost: Encodable {
    var next: String
    let limit: String
    let productID: String
    
    enum CodingKeys: String, CodingKey {
        case next, limit
        case productID = "product_id"
    }
}

struct PostAdd: Encodable {
    let title: String?
    let file: Data? //UploadFile? // 확장자 제한: jpg, png, jpeg, gif, pdf - 용량제한 10MB/파일 당 - 최대 파일 개수: 5개
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

struct DownloadImage: Encodable {
    let path: String
}

struct UserID: Encodable {
    let id: String
}

struct PostID: Encodable {
    let id: String
}

struct CommentMessage: Encodable {
    let content: String
}

struct CommentDelete: Encodable {
    let id: String
    let commentID: String
}

struct ProfileEdit: Encodable {
    let nick: String
    let phoneNum, birthDay: String?
    let profile: Data?
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
    let id: String
    let token: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case token, refreshToken
        case id = "_id"
    }
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

struct PostResponses: Decodable {
    let data: [PostResponse]
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct PostResponse: Decodable {
    let likes: [String]
    let image: [String]
    let hashTags: [String?]
    let comments: [Comment]
    let id: String
    let creator: Creator
    let time, title: String?
    let content, content1, content2, content3, content4, content5: String?
    let productID: String

    enum CodingKeys: String, CodingKey {
        case likes, image, hashTags, comments
        case id = "_id"
        case creator, time, title, content, content1, content2, content3, content4, content5
        case productID = "product_id"
    }
}

struct Comment: Decodable {
    let id, content, time: String?
    let creator: Creator
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content, time, creator
    }
}

struct CommentDeleteResponse: Decodable {
    let postID: String
}

struct Creator: Decodable {
    let id, nick: String
    let profile: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nick, profile
    }
}

struct MyProfile: Decodable {
    let posts: [String]
    let followers, following: [Follow]
    let id, nick: String
    let email, phoneNum, birthDay, profile: String?

    enum CodingKeys: String, CodingKey {
        case posts, followers, following
        case id = "_id"
        case email, nick, phoneNum, birthDay, profile
    }
}

struct Follow: Decodable {
    let id, nick, profile: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nick, profile
    }
}

struct FollowResponse: Decodable {
    let user, following: String
    let followingStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case user, following
        case followingStatus = "following_status"
    }
}

struct PostDelete: Decodable {
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
    }
}

struct LikeResponse: Decodable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
    
}
