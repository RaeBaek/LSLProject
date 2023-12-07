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
    case allPost(model: AllPost)
    case postAdd(model: PostAdd)
    case downloadImage(model: DownloadImage)
    case userPosts(model: UserID)
    case myProfile
    case commentAdd(model: CommentMessage, id: String)
    
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
        case .allPost, .postAdd:
            return "post"
        case .downloadImage(let model):
            return model.path
        case .myProfile:
            return "profile/me"
        case .userPosts(let model):
            return "post/user/\(model.id)"
        case .commentAdd(_, let id):
            return "post/\(id)/comment"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation, .login, .postAdd, .commentAdd:
            return .post
        case .accessToken, .withdraw, .allPost, .downloadImage, .myProfile, .userPosts:
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
            
        case .commentAdd(let model, _):
            return .requestJSONEncodable(model)
            
        case .accessToken, .withdraw, .downloadImage, .myProfile, .userPosts:
            return .requestPlain
            
        case .allPost(let model):
            return .requestParameters(parameters: ["next": model.next, "limit": model.limit, "product_id": model.productID], encoding: URLEncoding.queryString)
            
        case .postAdd(let model):
            
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
        case .withdraw, .allPost, .downloadImage, .myProfile, .userPosts:
            return ["Authorization": token, "SesacKey": key]
        case .postAdd:
            return ["Authorization": token, "SesacKey": key, "Content-Type": "multipart/form-data"]
        }
        
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
