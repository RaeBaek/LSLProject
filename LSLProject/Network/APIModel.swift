//
//  APIModel.swift
//  LSLProject
//
//  Created by 백래훈 on 11/15/23.
//

import Foundation

//MARK: - Encodable
struct Join: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String?
    let bitthDay: String?
}

struct EmailValidation: Encodable {
    let email: String
}
