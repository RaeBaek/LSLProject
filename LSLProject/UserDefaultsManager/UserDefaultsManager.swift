//
//  UserDefaultsManager.swift
//  LSLProject
//
//  Created by 백래훈 on 11/22/23.
//

import Foundation

enum UserDefaultsManagerDefaultValue: String {
    case email = "이메일 없음"
    case password = "비밀번호 없음"
    case id = "아이디 없음"
    case nickname = "닉네임 없음"
    case phoneNum, birthDay = ""
    case token = "토큰 없음"
    case refreshToken = "리프레시 토큰 없음"
}

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
        case phoneNum
        case birthDay
        case token
        case refreshToken
    }
    
    // 반복되는 코드를 RBDefaults 구조체를 활용하여 간결하게 구성해볼 수 있다.
    @RBDefaults(key: Key.email.rawValue, defaultValue: UserDefaultsManagerDefaultValue.email.rawValue)
    static var email
    
    @RBDefaults(key: Key.password.rawValue, defaultValue: UserDefaultsManagerDefaultValue.password.rawValue)
    static var password
    
    @RBDefaults(key: Key.id.rawValue, defaultValue: UserDefaultsManagerDefaultValue.id.rawValue)
    static var id
    
    @RBDefaults(key: Key.nickname.rawValue, defaultValue: UserDefaultsManagerDefaultValue.nickname.rawValue)
    static var nickname
    
    @RBDefaults(key: Key.phoneNum.rawValue, defaultValue: UserDefaultsManagerDefaultValue.phoneNum.rawValue)
    static var phoneNum
    
    @RBDefaults(key: Key.birthDay.rawValue, defaultValue: UserDefaultsManagerDefaultValue.birthDay.rawValue)
    static var birthDay
    
    @RBDefaults(key: Key.token.rawValue, defaultValue: UserDefaultsManagerDefaultValue.token.rawValue)
    static var token
    
    @RBDefaults(key: Key.refreshToken.rawValue, defaultValue: UserDefaultsManagerDefaultValue.refreshToken.rawValue)
    static var refreshToken
    
}
