//
//  LogoutViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/17/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LogoutViewController: BaseViewController {
    
    let backView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        return view
    }()
    
    let deleteTitle = {
        let view = UILabel()
        view.text = "로그아웃 하시겠어요?"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .bold)
        return view
    }()
    
    let deleteSubTitle = {
        let view = UILabel()
        view.text = "지금 로그아웃 하더라도 언제든 다시 로그인할 수 있습니다."
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 13, weight: .regular)
        return view
    }()
    
    let deleteLine = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let cancelLine = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let deleteButton = CustomButton(frame: .zero)
    let cancelButton = CustomButton(frame: .zero)
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = PostDeleteViewModel(repository: repository)
    
    private let diposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func bind() {
        
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
