//
//  CheckViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/19/23.
//

import UIKit

class CheckViewController: BaseViewController {
    
    let checkLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 30, weight: .regular)
        return view
    }()
    
    var signUpValues: [String?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let signUpValues else { return }
        print(signUpValues)
        checkLabel.text = "홈~~"
        
        
    }
    
    override func configureView() {
        super.configureView()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(checkLabel)
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        checkLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
}
