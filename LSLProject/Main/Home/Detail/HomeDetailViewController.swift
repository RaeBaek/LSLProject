//
//  HomeDetailViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

protocol SendData {
    func sendData(data: Data)
}

final class HomeDetailViewController: BaseViewController, SendData {
    
    private let detailTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(HomeDetailPostHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeDetailPostHeaderView.identifier)
        view.register(HomeDetailCommentCell.self, forCellReuseIdentifier: HomeDetailCommentCell.identifier)
        view.backgroundColor = .systemBackground
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.tableFooterView = UIView(frame: .zero)
        return view
    }()
    
    let commentWriteView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy var backView = {
        let view = CommentBackView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    let myProfileImage = ProfileImageView(frame: .zero)
    
    let commentTitle = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15, weight: .regular)
        view.textColor = .lightGray
        view.text = "@@@님에게 답글 남기기"
        return view
    }()
    
    let commentButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        return view
    }()
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = HomeDetailViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    var sendData: Data? {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    lazy var observeData = BehaviorRelay(value: sendData)
    
    var item: PostResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView.contentInset = .zero
        detailTableView.contentInsetAdjustmentBehavior = .never
        
        setNavigationBar()
        setTabBar()
        
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func sendData(data: Data) {
        sendData = data
//        detailTableView.reloadData()
    }
    
    private func bind() {
        guard let item else { return }
        
        let input = HomeDetailViewModel.Input(sendData: observeData,
                                              contentID: BehaviorRelay(value: item.id),
                                              commentButtonTap: commentButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.commentButtonTap
            .withUnretained(self)
            .bind { owner, _ in
                owner.commentViewController(item: item)
            }
            .disposed(by: disposeBag)
        
        output.postResponse
            .map { $0.comments }
            .bind(to: detailTableView.rx.items(cellIdentifier: HomeDetailCommentCell.identifier, cellType: HomeDetailCommentCell.self)) { row, element, cell in
                cell.setCell(element: element) {
                    cell.layoutIfNeeded()
                }
            }
            .disposed(by: disposeBag)
        
        detailTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        title = "스레드"
        navigationController?.navigationBar.isHidden = false
        
    }
    
    private func setTabBar() {
        
//        tabBarController?.tabBar.backgroundImage = UIImage()
//        tabBarController?.tabBar.shadowImage = UIImage()
//        tabBarController?.tabBar.isTranslucent = false
//        tabBarController?.tabBar.backgroundColor = .white
//        tabBarController?.tabBar.barTintColor = .white
        
    }
    
    private func commentViewController(item: PostResponse) {
        let vc = CommentViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        
        vc.post = item
        vc.sendDelegate = self
        
        self.present(nav, animated: true)
    }
    
    override func configureView() {
        super.configureView()
        
        [detailTableView, commentWriteView].forEach {
            view.addSubview($0)
        }
        
        [backView].forEach {
            commentWriteView.addSubview($0)
        }
        
        [myProfileImage, commentTitle, commentButton].forEach {
            backView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        detailTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        commentWriteView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        backView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        myProfileImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(20)
        }
        
        commentTitle.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(myProfileImage.snp.trailing).offset(6)
        }
        
        commentButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
}

extension HomeDetailViewController: UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeDetailPostHeaderView.identifier) as? HomeDetailPostHeaderView, let item else { return UIView() }
        
        header.setHeaderView(item: item) { [weak self] in
            guard let self else { return }
            UIView.setAnimationsEnabled(false)
            self.detailTableView.beginUpdates()
            header.layoutIfNeeded()
            self.detailTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        detailTableView.snp.remakeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(commentWriteView.snp.top)
        }
        
    }
    
}
