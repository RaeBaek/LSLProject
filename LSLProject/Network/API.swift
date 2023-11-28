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
    case postAdd(model: PostAdd)
    
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
        case .postAdd:
            return "post"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .emailValidation, .login, .postAdd:
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
            
        case .postAdd(let model):
            
            var postData: [MultipartFormData] = []
            
            print("---------- \(model.file)")
            print("---------- \(model.title)")
            print("---------- \(model.productID)")
            
            if let file = model.file {
                print("ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ")
//                let imageData = MultipartFormData(provider: .data(file), name: "file")
                let imageData2 = MultipartFormData(provider: .data(file), name: "file", fileName: "image.jpeg", mimeType: "image/jpeg")
                let imageData3 = MultipartFormData(provider: .data(file), name: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                let title = MultipartFormData(provider: .data((model.title?.data(using: .utf8)!)!), name: "title")
                let productId = MultipartFormData(provider: .data((model.productID?.data(using: .utf8)!)!), name: "product_id")
                
                print("!!!! \(imageData2)")
                
                postData.append(contentsOf: [imageData2, title, productId])
                
            }
            
            let title = MultipartFormData(provider: .data((model.title?.data(using: .utf8)!)!), name: "title")
            let productId = MultipartFormData(provider: .data((model.productID?.data(using: .utf8)!)!), name: "product_id")
            
            postData.append(contentsOf: [title, productId])
            
            return .uploadMultipart(postData)
            
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
        case .postAdd:
            return ["Authorization": token, "SesacKey": key, "Content-Type": "multipart/form-data"]
        }
        
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
