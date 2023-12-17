//
//  WithdrawViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/17/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WithdrawViewController: BaseViewController {
    
    let backView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        return view
    }()
    
    let deleteTitle = {
        let view = UILabel()
        view.text = "회원탈퇴를 하시겠어요?"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .bold)
        return view
    }()
    
    let deleteSubTitle = {
        let view = UILabel()
        view.text = "회원탈퇴를 하면 현재 계정의 모든 정보가 사라집니다.\n그래도 탈퇴를 원하시면 탈퇴 버튼을 누르세요."
        view.numberOfLines = 0
        view.textAlignment = .center
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
    
    let withdrawButton = CustomButton(frame: .zero)
    let cancelButton = CustomButton(frame: .zero)
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = WithdrawViewModel(repository: repository)
    
    private let diposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    private func bind() {
        
        let input = WithdrawViewModel.Input(withdrawButtonTap: withdrawButton.rx.tap,
                                            cancelButtonTap: cancelButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.withdrawStatus
            .withUnretained(self)
            .bind { owner, bool in
                if bool {
                    owner.changeRootViewController()
                }
            }
            .disposed(by: diposeBag)
        
    }
    
    // 로그아웃 화면 루트 뷰 체인지 작성중
    private func changeRootViewController() {
        let vc = SignInViewController()
        
        UserDefaultsManager.email = UserDefaultsManagerDefaultValue.email.rawValue
        UserDefaultsManager.password = UserDefaultsManagerDefaultValue.password.rawValue
        UserDefaultsManager.nickname = UserDefaultsManagerDefaultValue.nickname.rawValue
        UserDefaultsManager.profile = UserDefaultsManagerDefaultValue.profile.rawValue
        UserDefaultsManager.phoneNum = UserDefaultsManagerDefaultValue.phoneNum.rawValue
        UserDefaultsManager.token = UserDefaultsManagerDefaultValue.token.rawValue
        UserDefaultsManager.refreshToken = UserDefaultsManagerDefaultValue.refreshToken.rawValue
        
        
        let rootVC = UINavigationController(rootViewController: vc)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(rootVC)
    }
    
    override func configureView() {
        super.configureView()
        
        view.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.5)
        
        view.addSubview(backView)
        
        [deleteTitle, deleteSubTitle, deleteLine, cancelLine, withdrawButton, cancelButton].forEach {
            backView.addSubview($0)
        }
        
        withdrawButton.buttonSetting(title: "탈퇴", backgroundColor: .white, fontColor: .systemRed, fontSize: 15, fontWeight: .bold)
        
        cancelButton.buttonSetting(title: "취소", backgroundColor: .white, fontColor: .darkGray, fontSize: 15, fontWeight: .regular)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        backView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalToSuperview().multipliedBy(0.275)
        }
        
        deleteTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.centerX.equalToSuperview()
        }
        
        deleteSubTitle.snp.makeConstraints {
            $0.top.equalTo(deleteTitle.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        deleteLine.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        cancelLine.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(1.5)
            $0.width.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        withdrawButton.snp.makeConstraints {
            $0.top.equalTo(deleteLine.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(cancelLine.snp.top)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(cancelLine.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: false)
        
    }
    
}
