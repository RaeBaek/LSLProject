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
    
    let tableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        view.rowHeight = 50
        return view
    }()
    
    var value: Bool?
    
    var myPost = [
        Header(header: nil,
               items: [
                Bottom(title: "프로필에 고정", color: .black),
                Bottom(title: "답글을 남길 수 있는 사람", color: .black),
                Bottom(title: "좋아요 수 숨기기", color: .black)
        ]),
        Header(header: nil,
               items: [
                Bottom(title: "삭제", color: .systemRed)
        ])
    ]
    
    var userPost = [
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
    
    lazy var myPosts = BehaviorRelay<[Header]>(value: myPost)
    lazy var userPosts = BehaviorRelay<[Header]>(value: userPost)
    
    let repository = NetworkRepository()
    
    let disposeBag = DisposeBag()
    
    var deletePostID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    private func bind() {
        
        guard let value else { return }
        
        let dataSource = RxTableViewSectionedReloadDataSource<Header>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
                
                cell.textLabel?.text = item.title
                cell.textLabel?.textColor = item.color
                cell.textLabel?.font = .systemFont(ofSize: 12.5, weight: .medium)
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                
                return cell
            })
        
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
            .filter { $0.title == "삭제" }
            .withUnretained(self)
            .bind { owner, _ in
                print("모델 셀렉티드")
                owner.dismissViewController(id: owner.deletePostID!)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    func dismissViewController(id: String) {
        
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
