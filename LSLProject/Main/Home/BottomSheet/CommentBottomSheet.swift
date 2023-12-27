//
//  CommentBottomSheet.swift
//  LSLProject
//
//  Created by 백래훈 on 12/10/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class CommentBottomSheet: BaseViewController {
    
    let tableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        view.rowHeight = 50
        view.isScrollEnabled = false
        return view
    }()
    
    var myComment = [
        Header(header: nil,
               items: [
                Bottom(title: "답글 고정", color: .black),
                Bottom(title: "답글을 남길 수 있는 사람", color: .black),
                Bottom(title: "좋아요 수 숨기기", color: .black)
        ]),
        Header(header: nil,
               items: [
                Bottom(title: "수정", color: .systemRed),
                Bottom(title: "삭제", color: .systemRed)
        ])
    ]
    
    var userComment = [
        Header(header: nil,
               items: [
                Bottom(title: "팔로우 취소", color: .black),
                Bottom(title: "업데이트 안 보기", color: .black)
        ]),
        Header(header: nil,
               items: [
                Bottom(title: "모두에게 숨기기", color: .black),
                Bottom(title: "신고", color: .systemRed)
        ])
    ]
    
    lazy var myPosts = BehaviorRelay<[Header]>(value: myComment)
    lazy var userPosts = BehaviorRelay<[Header]>(value: userComment)
    
    let repository = NetworkRepository()
    
    let disposeBag = DisposeBag()
    
    var value: Bool?
    var commentRow: Int?
    var row: Int?
    var postID: String?
    var deleteCommentID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    private func bind() {
        guard let value, let row else { return }
        
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
            .filter { $0.title == "수정" }
            .withUnretained(self)
            .bind { owner, value in
                owner.dismissPostEdit(postID: owner.postID, commentID: owner.deleteCommentID, commentRow: owner.commentRow!, row: row)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Bottom.self)
            .filter { $0.title == "삭제" }
            .withUnretained(self)
            .bind { owner, _ in
                owner.dismissPostDelete(postID: owner.postID, commentID: owner.deleteCommentID, row: row)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    func dismissPostEdit(postID: String?, commentID: String?, commentRow: Int, row: Int) {
        
        let vc = CommentEditViewController()
        
        guard let presentingViewController = self.presentingViewController else { return }
        
        vc.commentRow = commentRow
        vc.row = row
        vc.postID = postID
        vc.commentID = commentID

        self.dismiss(animated: true) {
            let nav = UINavigationController(rootViewController: vc)
            presentingViewController.present(nav, animated: true)
        }
    }
    
    func dismissPostDelete(postID: String?, commentID: String?, row: Int) {
        
        let vc = PostDeleteViewController()
        
        guard let presentingViewController = self.presentingViewController else { return }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.row = row
        vc.reloadPostID = postID
        vc.deletePostID = postID
        vc.deleteCommentID = commentID

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

extension CommentBottomSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
