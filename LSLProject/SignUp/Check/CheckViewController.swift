//
//  CheckViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/19/23.
//

import UIKit

class CheckViewController: BaseViewController {
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let signUpValues else { return }
        
        print(signUpValues)
        
    }
    
    override func configureView() {
        super.configureView()
        
        view.backgroundColor = .systemBackground
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
