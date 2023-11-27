//
//  Extension + UITableViewCell.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import Foundation
import UIKit

extension UITableViewCell: ReusableProtocol {
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
