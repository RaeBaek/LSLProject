//
//  HomeTableViewHeader.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxDataSources

struct Post {
    let profileImage: String
    let userNickname: String
    let mainText: String
    let uploadTime: String
    let mainImage: String
    let status: String
}

struct Header: SectionModelType {
    
    typealias Item = Post
    
    var header: UIView
    var items: [Item]
        
}

extension Header {
    init(original: Header, items: [Post]) {
        self = original
        self.items = items
    }
}
