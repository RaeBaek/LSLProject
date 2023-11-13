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
    
    let emailTextField = {
        let view = UITextField()
        view.placeholder = "사용자 이름, 이메일 주소 또는 휴대폰 번호"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.backgroundColor = .white
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        view.leftViewMode = .always
        view.layer.cornerRadius = 16.5
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1
        view.keyboardType = .emailAddress
        return view
    }()
    
    let passwordTextField = {
        let view = UITextField()
        view.placeholder = "비밀번호"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.backgroundColor = .white
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        view.leftViewMode = .always
        view.layer.cornerRadius = 16.5
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1
        view.keyboardType = .alphabet
        return view
    }()
    
    let signInButton = {
        let view = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .capsule
        
        var titleAttr = AttributedString.init("로그인")
        titleAttr.font = .systemFont(ofSize: 15, weight: .regular)
        
        config.attributedTitle = titleAttr
        
        view.configuration = config
        
        return view
    }()
    
    let signUpButton = {
        let view = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .systemBlue
        config.baseBackgroundColor = .systemGray6
        config.cornerStyle = .capsule
        config.background.strokeColor = .systemBlue
        config.background.strokeWidth = 1
        
        var titleAttr = AttributedString.init("새 계정 만들기")
        titleAttr.font = .systemFont(ofSize: 15, weight: .regular)
        
        config.attributedTitle = titleAttr
        
        view.configuration = config
        
        view.addTarget(self, action: #selector(pushUserNameMakeViewController), for: .touchUpInside)
        
        return view
    }()
    
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
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func pushUserNameMakeViewController() {
        let vc = UserNameMakeViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func configureView() {
        view.backgroundColor = .systemGray6
        
        [logoImage, emailTextField, passwordTextField, signInButton, signUpButton, metaImage, metaLabel].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        logoImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
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
//            $0.centerY.equalTo(metaImage.snp.centerY)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
        }
    }
    
}
