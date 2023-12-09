//
//  HomeTableViewHeader.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxDataSources

struct Bottom {
    let title: String
    let color: UIColor
}

struct Header: SectionModelType {
    
    typealias Item = Bottom
    
    var header: String?
    var items: [Item]
        
}

extension Header {
    init(original: Header, items: [Bottom]) {
        self = original
        self.items = items
    }
}
