//
//  UserDefaultsManager.swift
//  LSLProject
//
//  Created by 백래훈 on 11/22/23.
//

import Foundation

@propertyWrapper
struct RBDefaults<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}

enum UserDefaultsManager {
    
    enum Key: String {
        case email
        case password
        case id
        case nickname
        case token
        case refreshToken
    }
    
    // 반복되는 코드를 RBDefaults 구조체를 활용하여 간결하게 구성해볼 수 있다.
    @RBDefaults(key: Key.email.rawValue, defaultValue: "이메일 없음")
    static var email
    
    @RBDefaults(key: Key.password.rawValue, defaultValue: "비밀번호 없음")
    static var password
    
    @RBDefaults(key: Key.id.rawValue, defaultValue: "아이디 없음")
    static var id
    
    @RBDefaults(key: Key.nickname.rawValue, defaultValue: "닉네임 없음")
    static var nickname
    
    @RBDefaults(key: Key.token.rawValue, defaultValue: "토큰 없음")
    static var token
    
    @RBDefaults(key: Key.refreshToken.rawValue, defaultValue: "리프레시 토큰 없음")
    static var refreshToken
    
}
