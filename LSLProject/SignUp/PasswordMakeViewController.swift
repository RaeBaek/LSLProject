//
//  PasswordMakeViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit

class PasswordMakeViewController: MakeViewController {
    
    let titleLabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        view.textAlignment = .left
        return view
    }()
    
    let descriptionLabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .regular)
        view.textAlignment = .left
        view.numberOfLines = 0
        return view
    }()
    
    let customTextField = UITextField.customTextField()
    
    let nextButton = UIButton.capsuleButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureView() {
        view.backgroundColor = .systemBackground
        
        [titleLabel, descriptionLabel, customTextField, nextButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaInsets).inset(16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        customTextField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(60)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(customTextField.snp.bottom).offset(25)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(45)
        }
    }
    
}
