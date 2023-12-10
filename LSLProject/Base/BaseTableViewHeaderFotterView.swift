//
//  BaseTableViewHeaderFotterView.swift
//  LSLProject
//
//  Created by 백래훈 on 12/10/23.
//

import UIKit
import Kingfisher

class BaseTableViewHeaderFotterView: UITableViewHeaderFooterView {
    
    let imageDownloadRequest = AnyModifier { request in
        var requestBody = request
        requestBody.setValue(UserDefaultsManager.token, forHTTPHeaderField: "Authorization")
        requestBody.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
        return requestBody
    }
    
}
