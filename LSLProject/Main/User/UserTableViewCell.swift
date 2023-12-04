//
//  UserTableViewCell.swift
//  LSLProject
//
//  Created by 백래훈 on 12/4/23.
//

import UIKit
import SnapKit

import RxSwift
import RxCocoa

class UserTableViewCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: UserTableViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureCell() {
        super.configureCell()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
