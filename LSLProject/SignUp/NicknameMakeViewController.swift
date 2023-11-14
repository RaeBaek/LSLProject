//
//  NicknameMakeViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit

class NicknameMakeViewController: MakeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "닉네임 만들기"
        descriptionLabel.text = "회원님만의 닉네임을 만드세요. 단, 중복은 안됩니다."
        customTextField.placeholder = "닉네임 (필수)"
        
        nextButton.addTarget(self, action: #selector(pushNextVieController), for: .touchUpInside)
        
    }
    
    @objc func pushNextVieController() {
        view.endEditing(true)
        let vc = PhoneNumberMakeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
