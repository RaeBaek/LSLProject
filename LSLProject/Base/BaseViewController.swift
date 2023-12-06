//
//  BaseViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/13/23.
//

import UIKit
import Kingfisher

class BaseViewController: UIViewController {
    
    let imageDownloadRequest = AnyModifier { request in
        var requestBody = request
        requestBody.setValue(UserDefaultsManager.token, forHTTPHeaderField: "Authorization")
        requestBody.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
        return requestBody
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        setConstraints()
        
    }
    
    func configureView() {
        view.backgroundColor = .systemBackground
        
    }
    
    func setConstraints() {
        
    }
}
