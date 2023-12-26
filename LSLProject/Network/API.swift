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
    case aPost(model: PostID)
    case allPost(model: AllPost)
    case postAdd(model: Post)
    case postEdit(model: Post, id: String)
    case postDel(model: PostID)
    case downloadImage(model: DownloadImage)
    case userPosts(model: UserID)
    case myProfile
    case userProfile(model: UserID)
    case profileEdit(model: ProfileEdit)
    case commentAdd(model: CommentMessage, id: String)
    case commentDel(model: CommentDelete)
    case follow(model: UserID)
    case unfollow(model: UserID)
    case like(model: UserID)
    case likes
    
}

extension SeSACAPI: TargetType {
    var baseURL: URL {
        URL(string: APIKey.sesacURL)! //27812: 테스트 서버, 27820: 본 서버
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
            
        case .aPost(let model):
            return "post/\(model.id)"
            
        case .allPost, .postAdd:
            return "post"
            
        case .postEdit(_, let id):
            return "post/\(id)"
            
        case .postDel(let model):
            return "post/\(model.id)"
            
        case .downloadImage(let model):
            return model.path
            
        case .myProfile, .profileEdit:
            return "profile/me"
            
        case .userProfile(let model):
            return "profile/\(model.id)"
            
        case .userPosts(let model):
            return "post/user/\(model.id)"
            
        case .commentAdd(_, let id):
            return "post/\(id)/comment"
            
        case .commentDel(let model):
            return "post/\(model.id)/comment/\(model.commentID)"
            
        case .follow(let model):
            return "follow/\(model.id)"
            
        case .unfollow(let model):
            return "follow/\(model.id)"
            
        case .like(let model):
            return "post/like/\(model.id)"
            
        case .likes:
            return "post/like/me"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .accessToken, .withdraw, .allPost, .downloadImage, .myProfile, .userPosts, .userProfile, .aPost, .likes:
            return .get
            
        case .signUp, .emailValidation, .login, .postAdd, .commentAdd, .follow, .like:
            return .post
            
        case .postEdit, .profileEdit:
            return .put
        
        case .postDel, .commentDel, .unfollow:
            return .delete
            
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
            
        case .commentAdd(let model, _):
            return .requestJSONEncodable(model)
            
        case .commentDel(let model):
            return .requestJSONEncodable(model)
            
        case .accessToken, .withdraw, .downloadImage, .myProfile, .userPosts, .postDel, .userProfile, .follow, .likes, .unfollow, .aPost, .like:
            return .requestPlain
            
        case .allPost(let model):
            return .requestParameters(parameters: ["next": model.next, "limit": model.limit, "product_id": model.productID], encoding: URLEncoding.queryString)
            
        case .postAdd(let model), .postEdit(let model, _):
            if let file = model.file {
                let imageData = MultipartFormData(provider: .data(file), name: "file", fileName: "image.jpg", mimeType: "image/jpg")
                let title = MultipartFormData(provider: .data((model.title?.data(using: .utf8)!) ?? Data()), name: "title")
                let productId = MultipartFormData(provider: .data((model.productID?.data(using: .utf8)!)!), name: "product_id")
                
                return .uploadMultipart([imageData, title, productId])
                
            } else {
                let title = MultipartFormData(provider: .data((model.title?.data(using: .utf8)!)!), name: "title")
                let productId = MultipartFormData(provider: .data((model.productID?.data(using: .utf8)!)!), name: "product_id")
                
                return .uploadMultipart([title, productId])
            }
            
        case .profileEdit(let model):
            if let file = model.profile {
                let imageData = MultipartFormData(provider: .data(file), name: "profile", fileName: "profileImage.jpg", mimeType: "profileImage/jpg")
                let nick = MultipartFormData(provider: .data((model.nick.data(using: .utf8) ?? Data())), name: "nick")
                let phoneNum = MultipartFormData(provider: .data((model.phoneNum?.data(using: .utf8) ?? Data())), name: "phoneNum")
                let birthDay = MultipartFormData(provider: .data((model.birthDay?.data(using: .utf8) ?? Data())), name: "birthDay")
                
                return .uploadMultipart([imageData, nick, phoneNum, birthDay])
            } else {
                let nick = MultipartFormData(provider: .data((model.nick.data(using: .utf8) ?? Data())), name: "nick")
                let phoneNum = MultipartFormData(provider: .data((model.phoneNum?.data(using: .utf8) ?? Data())), name: "phoneNum")
                let birthDay = MultipartFormData(provider: .data((model.birthDay?.data(using: .utf8) ?? Data())), name: "birthDay")
                
                return .uploadMultipart([nick, phoneNum, birthDay])
            }
        }
    }
    
    var headers: [String : String]? {
        let key = APIKey.sesacKey
        let token = UserDefaultsManager.token
        let refreshToken = UserDefaultsManager.refreshToken
        
        switch self {
        case .signUp, .emailValidation, .login:
            return ["Content-Type": "application/json", "SesacKey": key]
        case .commentAdd:
            return ["Content-Type": "application/json", "SesacKey": key, "Authorization": token]
        case .accessToken:
            return ["Authorization": token, "SesacKey": key, "Refresh": refreshToken]
        case .withdraw, .allPost, .downloadImage, .myProfile, .userPosts, .postDel, .commentDel, .userProfile, .follow, .unfollow, .aPost, .like, .likes:
            return ["Authorization": token, "SesacKey": key]
        case .postAdd, .postEdit, .profileEdit:
            return ["Authorization": token, "SesacKey": key, "Content-Type": "multipart/form-data"]
            
        }
        
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
