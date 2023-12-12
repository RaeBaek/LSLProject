//
//  UserViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

final class MyProfileViewController: BaseViewController, SendData {
    
    private let userTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(MyProfileTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MyProfileTableHeaderView.identifier)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.tableFooterView = UIView(frame: .zero)
        view.sectionFooterHeight = 0
        return view
    }()
    
    let repository = NetworkRepository()
    
    lazy var viewModel = MyProfileViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    var sendData = Data() {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    var observeData = PublishRelay<Data>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        
        bind()
        
        // 한 번 호출 필요
        sendData = Data()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recallMyPostAPI(notification:)), name: Notification.Name("recallPostAPI"), object: nil)
        
    }
    
    @objc func recallMyPostAPI(notification: NSNotification) {
        if let data = notification.userInfo?["recallPostAPI"] as? Data {
            self.sendData = data
        }
        
    }
    
    private func bind() {
        let input = MyProfileViewModel.Input(sendData: observeData)
        let output = viewModel.transform(input: input)
            
        output.userPosts
            .debug("userPosts")
            .map { $0.data }
            .bind(to: userTableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                cell.setCell(element: element) {
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
    
    func sendData(data: Data) {
        sendData = data
        
    }
    
    override func configureView() {
        super.configureView()
        
        [userTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setConstraints() {
        super.setConstraints()
        
//        userTableView.tableHeaderView?.snp.makeConstraints {
//            $0.height.equalTo(200)
//        }
        
        userTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    private func presentProfileEdit() {
        let vc = ProfileEditViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        self.present(nav, animated: true)
    }

}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyProfileTableHeaderView.identifier) as? MyProfileTableHeaderView else { return UIView() }
                
        // 헤더 쪽에서 viewModel에 바로 접근할 수 없다보니
        // 인스턴스를 넣어준다.
        header.test(viewModel)
        
        header.profileEditButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.presentProfileEdit()
            }
            .disposed(by: header.disposeBag)
        
        return header
    }
    
}
