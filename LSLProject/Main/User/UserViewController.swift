//
//  UserViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

final class UserViewController: BaseViewController, UIScrollViewDelegate {

    private let userTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        
        view.register(UserTableHeaderView.self, forHeaderFooterViewReuseIdentifier: UserTableHeaderView.identifier)
        view.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.tableFooterView = UIView(frame: .zero)
        view.sectionFooterHeight = 0
        return view
    }()
    
    private let viewModel = UserViewModel(reposity: NetworkRepository())
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        
    }
    
    private func bind() {
        
        let input = UserViewModel.Input(userToken: BehaviorRelay(value: UserDefaultsManager.token))
        let output = viewModel.transform(input: input)
        
        
        // 내 프로필 화면에서
        // 쓰레드같은 경우에는 이름, 아이디, 팔로워, 프로필 이미지 등을 보여주고 있음
        // tableHeaderView에 삽입 그리고 <내 프로필 조회> API 사용
        // 프로필 아래로 내가 작성한 포스트들을 보여주고 있는데
        // 유저별 작성한 포스트 조회 API 사용해야 할듯 (본인 포함)
        // headerView에는 내 프로필 조회를
        // cell 에서는 포스트 조회 API를 사용해야할 듯 함.
        output.items
            .map { value in
                return value.posts
            }
            .bind(to: userTableView.rx.items(cellIdentifier: UserTableViewCell.identifier, cellType: UserTableViewCell.self)) { row, element, cell in
                
            }
            .disposed(by: disposeBag)
        
        userTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func configureView() {
        super.configureView()
        
        [userTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        userTableView.tableHeaderView?.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        
        userTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }

}

extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserTableHeaderView.identifier) as? UserTableHeaderView else { return UIView() }
        
        return header
    }
}
