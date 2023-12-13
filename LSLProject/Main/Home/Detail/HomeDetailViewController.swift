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
    func sendData(data: Void)
}

final class HomeDetailViewController: BaseViewController, SendData {
    
    deinit {
        print("HomeDetailViewController Deinit!!!!")
    }
    
    private let detailTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(HomeDetailPostHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeDetailPostHeaderView.identifier)
        view.register(HomeDetailCommentCell.self, forCellReuseIdentifier: HomeDetailCommentCell.identifier)
        view.backgroundColor = .systemBackground
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.contentInset = .zero
        view.contentInsetAdjustmentBehavior = .never
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
        return view
    }()
    
    let commentButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var viewModel = HomeDetailViewModel(repository: NetworkRepository())
    
    private let disposeBag = DisposeBag()
    
    var sendData: Void = () {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    lazy var observeData = BehaviorRelay(value: ())
    
    var item: PostResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setTabBar()
        setCommentWriteView()
        
        bind()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recallAllCommentAPI(notification:)), name: Notification.Name("recallCommentAPI"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteDtailViewController(notification:)), name: Notification.Name("deleteDtailViewController"), object: nil)
        
    }
    
    @objc func deleteDtailViewController(notification: NSNotification) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func recallAllCommentAPI(notification: NSNotification) {
        if let data = notification.userInfo?["recallCommentAPI"] as? Void {
            self.sendData = data
            // 스크롤!
            if detailTableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                self.detailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func sendData(data: Void) {
        self.sendData = data
        // 스크롤!
        if detailTableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
            self.detailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        
    }
    
    private func setCommentWriteView() {
        guard let item else { return }
        commentTitle.text = "\(item.creator.nick)님에게 답글 남기기..."
        
        let myProfile = UserDefaultsManager.profile
        
        if myProfile != "basicUser" {
            let myProfileImageUrl = URL(string: APIKey.sesacURL + myProfile)
            myProfileImage.kf.setImage(with: myProfileImageUrl, options: [.requestModifier(imageDownloadRequest)])
        } else {
            myProfileImage.image = UIImage(named: myProfile)
        }
        
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
            .bind(to: detailTableView.rx.items(cellIdentifier: HomeDetailCommentCell.identifier, cellType: HomeDetailCommentCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                
                cell.selectionStyle = .none
                
                cell.setCell(element: element) {
                    cell.layoutIfNeeded()
                }
                
                cell.moreButton.rx.tap
                    .withLatestFrom(BehaviorRelay(value: element.creator.id), resultSelector: { _, id in
                        return id
                    })
                    .withUnretained(self)
                    .bind { owner, value in
                        if value == UserDefaultsManager.id {
                            owner.presentCommentBottomSheet(value: true, postID: item.id, commentID: element.id)
                        } else {
                            owner.presentCommentBottomSheet(value: false, postID: item.id, commentID: nil)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        detailTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    private func presentCommentBottomSheet(value: Bool, postID: String?, commentID: String?) {
        
        let vc = CommentBottomSheet()
        
        vc.modalPresentationStyle = .pageSheet
        vc.value = value
        vc.postID = postID
        vc.deleteCommentID = commentID
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in
                    return 300
                }
            ]
            
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
        }
        
        self.present(vc, animated: true)
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
    
    private func presentPostBottomSheet(value: Bool, id: String) {
        
        let vc = PostBottomSheet()
        
        vc.modalPresentationStyle = .pageSheet
        vc.value = value
        vc.deletePostID = id
        
        if let sheet = vc.sheetPresentationController {
            
            sheet.detents = [
                .custom { _ in
                    return 300
                }
            ]
            
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
        }
        
        self.present(vc, animated: true)
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
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        commentWriteView.snp.makeConstraints {
            $0.top.equalTo(detailTableView.snp.bottom)
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
        
        // homeVC에서 cell 내의 버튼을 bind 구문에서 setCell과 같이 다루었듯이
        // homeDetailVC의 header 내의 버튼은 여기서 다루어보자!
        // homeViewModel에 있는 input, output과 transform 메서드는 삭제하도록!
        
        header.moreButton.rx.tap
            .withUnretained(self)
            .bind { owner, value in
                if item.creator.id == UserDefaultsManager.id {
                    owner.presentPostBottomSheet(value: true, id: item.id)
                } else {
                    owner.presentPostBottomSheet(value: false, id: item.id)
                }
            }
            .disposed(by: header.disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
}

extension HomeDetailViewController: UISheetPresentationControllerDelegate {
    
}
