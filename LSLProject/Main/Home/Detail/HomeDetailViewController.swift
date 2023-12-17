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
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = HomeDetailViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    var sendDelegate: SendData?
    
    var scrollDelegate: ScrollToBottom?
    
    var sendData: Void = () {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    lazy var observeData = BehaviorRelay(value: ())
    
    var item: PostResponse?
    var homeRow: Int?
    var postID: String?
    
    var heartPostList: [String: Bool] = [:]
    var heartCount: [String: Int] = [:]
    var commentCount: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommentWriteView()
        bind()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recallAllCommentAPI(notification:)), name: Notification.Name("recallCommentAPI"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteDtailViewController(notification:)), name: Notification.Name("deleteDtailViewController"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        setTabBar()
        
    }
    
    @objc func deleteDtailViewController(notification: NSNotification) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // 댓글 삭제했을 때 (NotificationCenter)
    @objc func recallAllCommentAPI(notification: NSNotification) {
        guard let homeRow, let postID else { return }
        
        if let data = notification.userInfo?["recallCommentAPI"] as? Void {
            // 상세화면은 당연히 갱신해주어야하며
            self.sendData = data
            // 홈화면으로 뒤로가기했을 때 또한 변화를 알려줘야하므로 전달!
//            self.scrollDelegate?.reloadSubComment(row: homeRow, id: postID)
            // 스크롤!
            if detailTableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                detailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
    }
    
    // 댓글 추가했을 때 (Delegate Pattern)
    func sendData(data: Void) {
//        guard let row, let postID else { return }
        
        self.sendData = data
//        self.scrollDelegate?.reloadAddComment(row: row, id: postID)
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
        guard let item , let homeRow, let postID else { return }
        
        let input = HomeDetailViewModel.Input(sendData: observeData,
                                              contentID: BehaviorRelay(value: item.id),
                                              commentButtonTap: commentButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.commentButtonTap
            .withUnretained(self)
            .bind { owner, _ in
                owner.commentViewController(item: item, row: homeRow, id: postID)
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
                            owner.presentCommentBottomSheet(value: true, postID: item.id, commentID: element.id, row: homeRow)
                        } else {
                            owner.presentCommentBottomSheet(value: false, postID: item.id, commentID: nil, row: homeRow)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        detailTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    private func presentCommentBottomSheet(value: Bool, postID: String?, commentID: String?, row: Int) {
        let vc = CommentBottomSheet()
        
        vc.modalPresentationStyle = .pageSheet
        vc.value = value
        vc.row = row
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
    
    private func commentViewController(item: PostResponse, row: Int, id: String) {
        let vc = CommentViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        
        vc.post = item
        vc.row = row
        vc.postID = id
        vc.sendDelegate = self
//        vc.scrollDelegate = self
        
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
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeDetailPostHeaderView.identifier) as? HomeDetailPostHeaderView, let item, let homeRow else { return UIView() }
        
        header.test(viewModel)
        header.postID = item.id
        
        header.setHeaderView { [weak self] in
            guard let self else { return }
            UIView.setAnimationsEnabled(false)
            self.detailTableView.beginUpdates()
            
            header.layoutIfNeeded()
            
            self.detailTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
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
        
        header.heartButton.rx.tap
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestLike(id: item.id)
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                switch result {
                case .success(let data):
                    print("좋아요 상태 \(data.likeStatus)")
                    
                    if data.likeStatus {
                        header.heartButton.setSymbolImage(image: "heart.fill", size: 22, color: .systemRed)
                    } else {
                        header.heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
                    }
                    
                    // 버튼 변경 후 이벤트 보내기!
                    owner.sendData = ()
                    // delegate 패턴을 이용하여 reload 준비
                    owner.scrollDelegate?.reloadHeart(row: homeRow, id: item.id, status: data.likeStatus)
                    
                case .failure(let error):
                    guard let likeError = LikeError(rawValue: error.rawValue) else {
                        print("좋아요 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 좋아요 에러 \(likeError.message)")
                }
            })
            .disposed(by: header.disposeBag)
        
        // sendData에서 이벤트를 쏠때마다 실행
        observeData
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestAPost(id: item.id)
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                switch result {
                case .success(let data):
                    print("포스트 불러오기 성공!")
                    header.statusLabel.text = "\(data.comments.count) 답글, \(data.likes.count) 좋아요"
//                    header.layoutIfNeeded()
                    
                case .failure(let error):
                    guard let aPostError = AllPostError(rawValue: error.rawValue) else {
                        print("포스트 불러오기 에러.. \(error.message)")
                        return
                    }
                    print("커스텀 포스트 불러오기 에러 \(aPostError.message)")
                }
            })
            // header의 disposeBag이 아닌 vc의 disposeBag 사용
            .disposed(by: disposeBag)
        
        header.commentButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.commentViewController(item: item, row: homeRow, id: item.id)
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
