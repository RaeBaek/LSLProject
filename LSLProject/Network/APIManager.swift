//
//  APIManager.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit
import Moya

final class APIManager {
    
    static let shared = APIManager()
    
    private init() { }
    
    private let provider = MoyaProvider<SeSACAPI>()
    
    func emailValidationAPI(email: String, completionHandler: @escaping (Int, String) -> Void) {
        let data = EmailValidation(email: email)
        provider.request(.emailValidation(model: data)) { result in
            switch result {
            case .success(let value):
                print("Success: \(value.statusCode)")
                
                let result = try! JSONDecoder().decode(EmailValidationResponse.self, from: value.data)
                
                print("Result: \(result)")
                
                completionHandler(value.statusCode, result.message)
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
}

