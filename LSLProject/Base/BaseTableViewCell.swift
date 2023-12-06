//
//  BaseTableViewCell.swift
//  LSLProject
//
//  Created by 백래훈 on 11/25/23.
//

import UIKit
import Kingfisher

class BaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: BaseTableViewCell.identifier)
        
        configureCell()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageDownloadRequest = AnyModifier { request in
        var requestBody = request
        requestBody.setValue(UserDefaultsManager.token, forHTTPHeaderField: "Authorization")
        requestBody.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
        return requestBody
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    func configureCell() {
        
    }
    
    func setConstraints() {
        
    }
}
