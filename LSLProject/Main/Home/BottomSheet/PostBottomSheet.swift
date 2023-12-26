//
//  PostBottomSheet.swift
//  LSLProject
//
//  Created by 백래훈 on 12/9/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class PostBottomSheet: BaseViewController {
    
    private let tableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        view.rowHeight = 50
        view.isScrollEnabled = false
        return view
    }()
    
    var value: Bool?
    
    private var myPost = [
        Header(header: nil,
               items: [
                Bottom(title: "프로필에 고정", color: .black),
                Bottom(title: "답글을 남길 수 있는 사람", color: .black),
                Bottom(title: "좋아요 수 숨기기", color: .black)
        ]),
        Header(header: nil,
               items: [
                Bottom(title: "수정", color: .systemRed),
                Bottom(title: "삭제", color: .systemRed)
        ])
    ]
    
    private var userPost = [
        Header(header: nil,
               items: [
                Bottom(title: "업데이트 안보기", color: .black),
                Bottom(title: "차단", color: .systemRed)
        ]),
        Header(header: nil,
               items: [
                Bottom(title: "숨기기", color: .black),
                Bottom(title: "신고", color: .systemRed)
        ])
    ]
    
    private lazy var myPosts = BehaviorRelay<[Header]>(value: myPost)
    private lazy var userPosts = BehaviorRelay<[Header]>(value: userPost)
    
    private let repository = NetworkRepository()
    
    private let disposeBag = DisposeBag()
    
    var postID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    private func bind() {
        
        guard let value else { return }
        
        let dataSource = RxTableViewSectionedReloadDataSource<Header> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
            
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = item.color
            cell.textLabel?.font = .systemFont(ofSize: 12.5, weight: .medium)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            return cell
        }
        
        if value {
            myPosts
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            
        } else {
            userPosts
                .bind(to: tableView.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
        }
        
        tableView.rx.modelSelected(Bottom.self)
            .filter { $0.title == "수정" }
            .withUnretained(self)
            .bind { owner, _ in
                owner.dismissPostEdit(id: owner.postID!)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Bottom.self)
            .filter { $0.title == "삭제" }
            .withUnretained(self)
            .bind { owner, _ in
                owner.dismissPostDelete(id: owner.postID!)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    func dismissPostEdit(id: String) {
        let vc = PostEditViewController()
        
        guard let presentingViewController = self.presentingViewController else { return }
        
        vc.editPostID = id

        self.dismiss(animated: true) {
            let nav = UINavigationController(rootViewController: vc)
            presentingViewController.present(nav, animated: true)
        }
    }
    
    func dismissPostDelete(id: String) {
        let vc = PostDeleteViewController()
        
        guard let presentingViewController = self.presentingViewController else { return }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.deletePostID = id

        self.dismiss(animated: true) {
            presentingViewController.present(vc, animated: false)
        }
    }
    
    override func configureView() {
        super.configureView()
        
        view.addSubview(tableView)
        
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
}

extension PostBottomSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
