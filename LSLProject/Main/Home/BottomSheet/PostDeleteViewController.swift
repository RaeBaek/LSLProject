//
//  PostDeleteViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/9/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PostDeleteViewController: BaseViewController {
    
    let backView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        return view
    }()
    
    let deleteTitle = {
        let view = UILabel()
        view.text = "게시물을 삭제하시겠어요?"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .bold)
        return view
    }()
    
    let deleteSubTitle = {
        let view = UILabel()
        view.text = "이 게시물을 삭제하면 복원할 수 없습니다."
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
    
    var deletePostID: String?
    var deleteCommentID: String?
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = PostDeleteViewModel(repository: repository)
    
    private let diposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    private func bind() {
        
        // 게시물 삭제, 댓글 삭제 모두 게시글의 id는 필요하다.
        if let deleteCommentID {
            // 댓글은 댓글 id도 필요!
            if let deletePostID {
                let input = PostDeleteViewModel.CommentInput(deleteCommentButtonTap: deleteButton.rx.tap,
                                                             deletePostID: BehaviorRelay(value: deletePostID),
                                                             deleteCommentID: BehaviorRelay(value: deleteCommentID))
                
                let output = viewModel.commentTransform(input: input)
                
                output
                    .deleteCommentStatus
                    .withUnretained(self)
                    .bind { owner, value in
                        if value {
                            NotificationCenter.default.post(name: Notification.Name("recallCommentAPI"), object: nil, userInfo: ["recallCommentAPI": Data()])
                            owner.dismiss(animated: false)
                        }
                    }
                    .disposed(by: diposeBag)
            }
        } else {
            if let deletePostID {
                let input = PostDeleteViewModel.PostInput(deletePostButtonTap: deleteButton.rx.tap,
                                                          deletePostID: BehaviorRelay(value: deletePostID))
                
                let output = viewModel.postTransform(input: input)
                
                output.deletePostStatus
                    .withUnretained(self)
                    .bind { owner, value in
                        if value {
                            NotificationCenter.default.post(name: Notification.Name("recallPostAPI"), object: nil, userInfo: ["recallPostAPI": Data()])
                            NotificationCenter.default.post(name: Notification.Name("recallMyPostAPI"), object: nil, userInfo: ["recallMyPostAPI": Data()])
                            owner.dismiss(animated: false)
                        }
                    }
                    .disposed(by: diposeBag)
            }
        }
        
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: false)
        
    }
    
    override func configureView() {
        super.configureView()
        
        // 이거 진짜 골 때리네 ㅋㅋ
        // 왜 opacity를 그냥 주면 하위뷰도 같이 먹는건가..!!!
        view.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.5)
        
        view.addSubview(backView)
        
        [deleteTitle, deleteSubTitle, deleteLine, cancelLine, deleteButton, cancelButton].forEach {
            backView.addSubview($0)
        }
        
        deleteButton.buttonSetting(title: "삭제", backgroundColor: .white, fontColor: .systemRed, fontSize: 15, fontWeight: .bold)
        
        cancelButton.buttonSetting(title: "취소", backgroundColor: .white, fontColor: .darkGray, fontSize: 15, fontWeight: .regular)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        backView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalToSuperview().multipliedBy(0.25)
        }
        
        deleteTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.centerX.equalToSuperview()
        }
        
        deleteSubTitle.snp.makeConstraints {
            $0.top.equalTo(deleteTitle.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
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
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(deleteLine.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(cancelLine.snp.top)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(cancelLine.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
    }
    
}
