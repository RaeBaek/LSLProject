//
//  MakeViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/14/23.
//

import UIKit

class MakeViewController: BaseViewController {
    
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
    
    let backBarbutton = {
        let view = UIBarButtonItem()
        view.title = nil
        view.tintColor = .black
        return view
    }()
    
    let stackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.distribution = .fill
        return view
    }()
    
    let statusLabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 12, weight: .regular)
        view.textColor = .systemRed
        view.isHidden = true
        return view
    }()
    
    let customTextField = UITextField.customTextField()
    
    let nextButton = UIButton.capsuleButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = backBarbutton
        nextButton.isEnabled = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func configureView() {
        view.backgroundColor = .systemGray6
        
        [titleLabel, descriptionLabel, stackView, nextButton].forEach {
            view.addSubview($0)
        }
        
        [customTextField, statusLabel].forEach {
            stackView.addArrangedSubview($0)
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
//            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
//            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(60)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
//        statusLabel.snp.makeConstraints {
//            $0.top.equalTo(customTextField.snp.bottom).offset(10)
//            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
//        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(25)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(45)
        }
    }
    
}
