//
//  UserProfileViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/10/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class UserProfileViewController: BaseViewController {
    
    deinit {
        print("UserProfileViewController Deinit!!")
    }
    
    lazy var moreBarbutton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: nil)
        view.tintColor = .black
        return view
    }()
    
    private let userTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(UserProfileTableHeaderView.self, forHeaderFooterViewReuseIdentifier: UserProfileTableHeaderView.identifier)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.tableFooterView = UIView(frame: .zero)
        view.sectionFooterHeight = 0
        return view
    }()
    
    var userID: String?
    
    let repository = NetworkRepository()
    
    private lazy var viewModel = UserProfileViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    var followButtonStatus = Data() {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    var observeData = PublishRelay<Data>()//BehaviorRelay(value: followButtonStatus)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        bind()
        
        followButtonStatus = Data()
        
    }
    
    func bind() {
        guard let userID else { return }
        
        let input = UserProfileViewModel.Input(sendData: observeData,
                                               userID: BehaviorRelay(value: userID))
        
        let output = viewModel.transform(input: input)
        
        output.userPosts
            .map { $0.data }
            .bind(to: userTableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { [weak self] row, element, cell in
                
                cell.setCell(element: element) {
                    guard let self else { return }
                    UIView.setAnimationsEnabled(false)
                    self.userTableView.beginUpdates()
                    cell.layoutIfNeeded()
                    self.userTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
            }
            .disposed(by: disposeBag)
        
        userTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.rightBarButtonItem = moreBarbutton
    }
    
    override func configureView() {
        super.configureView()
        
        [userTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        userTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserProfileTableHeaderView.identifier) as? UserProfileTableHeaderView, let userID else { return UIView() }
        
        header.test(viewModel)
        
//        header.setHeaderView(sendData: observeData, userID: BehaviorRelay(value: userID))
        
        let followButton = header.followButton
        
        followButton.rx.tap
            .filter { followButton.configuration?.baseBackgroundColor == .black }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestFollow(id: userID)
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                switch result {
                case .success(_):
                    print("팔로우 성공!")
                    owner.followButtonStatus = Data()
                case .failure(let error):
                    guard let followError = FollowError(rawValue: error.rawValue) else {
                        print("팔로우 공통 에러입니다. \(error.message)")
                        return
                    }
                    print("팔로우 커스템 에러입니다. \(followError.message)")
                }
            })
            .disposed(by: header.disposeBag)
        
        followButton.rx.tap
            .filter { followButton.configuration?.baseBackgroundColor == .white }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestUnFollow(id: userID)
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                switch result {
                case .success(_):
                    print("언팔로우 성공!")
                    owner.followButtonStatus = Data()
                case .failure(let error):
                    guard let unfollowError = UnFollowError(rawValue: error.rawValue) else {
                        print("언팔로우 공통 에러입니다. \(error.message)")
                        return
                    }
                    print("언팔로우 커스템 에러입니다. \(unfollowError.message)")
                }
            })
            .disposed(by: header.disposeBag)
        
        return header
    }
}
