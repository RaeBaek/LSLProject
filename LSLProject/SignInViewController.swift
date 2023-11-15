//
//  SignInViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/13/23.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SignInViewController: BaseViewController {
    
    let logoImage = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "instagramSVG")
        return view
    }()
    
    let backBarbutton = {
        let view = UIBarButtonItem()
        view.title = nil
        view.tintColor = .black
        return view
    }()
    
    let emailTextField = UITextField.customTextField()
    let passwordTextField = UITextField.customTextField()
    
    let signInButton = UIButton.capsuleButton(title: "로그인")
    let signUpButton = UIButton.signUpButton(title: "새 계정 만들기")
    
    let metaImage = {
        let view = UIImageView()
        view.image = UIImage(named: "meta")
        return view
    }()
    
    let metaLabel = {
        let view = UILabel()
        view.text = "Meta"
        view.textColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        view.font = .systemFont(ofSize: 15, weight: .medium)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.placeholder = "사용자 이름, 이메일 주소 또는 휴대폰 번호"
        passwordTextField.placeholder = "비밀번호"
        signUpButton.addTarget(self, action: #selector(pushUserNameMakeViewController), for: .touchUpInside)
        
        self.navigationItem.backBarButtonItem = backBarbutton
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func pushUserNameMakeViewController() {
        view.endEditing(true)
        
        let vc = EmailAddressViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
        view.backgroundColor = .systemGray6
        
        [logoImage, emailTextField, passwordTextField, signInButton, signUpButton, metaImage, metaLabel].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        logoImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.size.equalTo(60)
        }
        
        emailTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(60)
        }
        
        signInButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(signInButton.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        metaImage.snp.makeConstraints {
            $0.top.equalTo(signUpButton.snp.bottom).offset(10)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
            $0.centerX.equalToSuperview().multipliedBy(0.9)
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        
        metaLabel.snp.makeConstraints {
            $0.leading.equalTo(metaImage.snp.trailing).offset(3)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
        }
    }
    
}
