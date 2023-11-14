//
//  PasswordMakeViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit

class PasswordMakeViewController: MakeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "비밀번호 만들기"
        descriptionLabel.text = "다른 사람이 추측할 수 없는 6자 이상의 문자 또는 숫자로 비밀번호를 만드세요."
        customTextField.placeholder = "비밀번호 (필수)"
        
        nextButton.addTarget(self, action: #selector(pushNextVieController), for: .touchUpInside)
    }
    
    @objc func pushNextVieController() {
        view.endEditing(true)
        let vc = NicknameMakeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
