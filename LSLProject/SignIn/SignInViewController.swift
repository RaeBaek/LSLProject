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

final class SignInViewController: BaseViewController {
    
    private let logoImage = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "instagramSVG")
        return view
    }()
    
    private let backBarbutton = {
        let view = UIBarButtonItem()
        view.title = nil
        view.tintColor = .black
        return view
    }()
    
    private let stackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = .fill
        return view
    }()
    
    private let emailTextField = UITextField.customTextField()
    private let passwordTextField = UITextField.customTextField()
    
    private let statusLabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 12, weight: .regular)
        view.textColor = .systemRed
        view.isHidden = true
        return view
    }()
    
    private let signInButton = UIButton.capsuleButton(title: "로그인")
    private let signUpButton = UIButton.signUpButton(title: "새 계정 만들기")
    
    private let metaImage = {
        let view = UIImageView()
        view.image = UIImage(named: "meta")
        return view
    }()
    
    private let metaLabel = {
        let view = UILabel()
        view.text = "Meta"
        view.textColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        view.font = .systemFont(ofSize: 15, weight: .medium)
        return view
    }()
    
    private let viewModel = SignInViewModel(repository: NetworkRepository())
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.placeholder = "사용자 이름, 이메일 주소 또는 휴대폰 번호"
        emailTextField.keyboardType = .alphabet
        emailTextField.isSecureTextEntry = false
        emailTextField.textContentType = .oneTimeCode
        
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.keyboardType = .alphabet
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .oneTimeCode
        
        self.navigationItem.backBarButtonItem = backBarbutton
        
        bind()
        
    }
    
    private func bind() {
        let input = SignInViewModel.Input(emailText: emailTextField.rx.text.orEmpty, passwordText: passwordTextField.rx.text.orEmpty, signInButtonClicked: signInButton.rx.tap, signUpButtonClicked: signUpButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.textStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
        output.borderStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.emailTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
                owner.passwordTextField.layer.borderColor = value ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
        
        output.outputText
            .withUnretained(self)
            .bind { owner, value in
                owner.statusLabel.text = value
            }
            .disposed(by: disposeBag)
        
        output.loginStatus
            .withUnretained(self)
            .bind { owner, _ in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
        output.signUpStatus
            .withUnretained(self)
            .bind { owner, _ in
                owner.pushEmailAddressViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func pushEmailAddressViewController() {
        view.endEditing(true)
        
        let vc = EmailAddressViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func changeRootViewController() {
        let vc = MainHomeViewController()
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc, animated: false)
    }
    
    override func configureView() {
        super.configureView()
        
        view.backgroundColor = .systemGray6
        
        [logoImage, emailTextField, passwordTextField, stackView, signInButton, signUpButton, metaImage, metaLabel].forEach {
            view.addSubview($0)
        }
        
        [emailTextField, passwordTextField, statusLabel].forEach {
            stackView.addArrangedSubview($0)
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
            $0.height.equalTo(60)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        signInButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(25)
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
