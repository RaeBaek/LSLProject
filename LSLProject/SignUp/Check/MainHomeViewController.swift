//
//  MainHomeViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/19/23.
//

import UIKit
import RxSwift
import RxCocoa

final class MainHomeViewController: BaseViewController {
    
    private let homeTableView = {
        let view = UITableView()
        view.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        view.rowHeight = UITableView.automaticDimension
        return view
    }()
    
    private let checkLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 30, weight: .regular)
        return view
    }()
    
    private let withdrawButton = {
        let view = UIButton()
        view.setTitle("회원탈퇴", for: .normal)
        view.backgroundColor = .lightGray
        view.tintColor = .yellow
        return view
    }()
    
    let viewModel = MainHomeViewModel(repository: NetworkRepository())
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    func bind() {
        let input = MainHomeViewModel.Input(withdraw: withdrawButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        let data = Observable.of([1, 2, 3, 4, 5])
        
        data
            .observe(on: MainScheduler.instance)
            .bind(to: homeTableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { (row, element, cell) in
                cell.selectionStyle = .none
                cell.separatorInset = .zero
            }
            .disposed(by: disposeBag)
        
        output.check
            .withUnretained(self)
            .bind { owner, value in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func changeRootViewController() {
        let vc = SignInViewController()
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc)
    }
    
    override func configureView() {
        super.configureView()
        
        view.backgroundColor = .systemBackground
        
        [homeTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        homeTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
//        checkLabel.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
//        
//        withdrawButton.snp.makeConstraints {
//            $0.top.equalTo(checkLabel.snp.bottom).offset(10)
//            $0.centerX.equalToSuperview()
//            $0.size.equalTo(100)
//        }
        
    }
    
}
