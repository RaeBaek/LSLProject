//
//  Extension + UITableHeaderFooterView.swift
//  LSLProject
//
//  Created by 백래훈 on 11/27/23.
//

import UIKit

extension UITableViewHeaderFooterView: ReusableProtocol {
    
    static var identifier: String {
        return String(describing: self)
        
    }
}
