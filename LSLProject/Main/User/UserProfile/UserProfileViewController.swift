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

final class UserProfileViewController: BaseViewController, SendData, ScrollToBottom {
    
    deinit {
        print("UserProfileViewController Deinit!!")
    }
    
    private lazy var backBarbutton = {
        let view = UIBarButtonItem(title: "뒤로", style: .plain, target: self, action: nil)
        view.tintColor = .black
        return view
    }()
    
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
        view.refreshControl = UIRefreshControl()
        return view
    }()
    
    var userID: String?
    
    let repository = NetworkRepository()
    
    private lazy var viewModel = UserProfileViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    var sendData: Void = Void() {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    var observeData = BehaviorRelay(value: ())
    
    var heartPostList: [String: Bool] = [:]
    var heartCount: [String: Int] = [:]
    var commentCount: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        // 유저 화면 -> 게시글 상세화면 -> 댓글 작성 modal 순서일 경우 delegate 패턴이 아닌 noti 활용
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAddComment(notification:)), name: Notification.Name("reloadComment"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSubComment(notification:)), name: Notification.Name("reloadSubComment"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        
    }
    
    @objc func reloadAddComment(notification: NSNotification) {
        if let row = notification.userInfo?["row"] as? Int, let postID = notification.userInfo?["postID"] as? String {
            
            self.reloadAddComment(row: row, id: postID)
            
        }
    }
    
    @objc func reloadSubComment(notification: NSNotification) {
        if let row = notification.userInfo?["row"] as? Int, let postID = notification.userInfo?["postID"] as? String {
            
            self.reloadSubComment(row: row, id: postID)
            
        }
    }
    
    func bind() {
        guard let userID else { return }
        
        let input = UserProfileViewModel.Input(refreshing: userTableView.refreshControl?.rx.controlEvent(.valueChanged),
                                               sendData: observeData,
                                               userID: BehaviorRelay(value: userID))
        
        let output = viewModel.transform(input: input)
        
        output.userPosts
            .map { $0.data }
            .bind(to: userTableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                
                cell.setCell(element: element) {
                    UIView.setAnimationsEnabled(false)
                    self.userTableView.beginUpdates()
                    
                    // 먼저 서버에서 받은 데이터에서 내가 좋아요 한 게시물이라면?
                    if element.likes.contains(UserDefaultsManager.id) {
                        // 좋아요 한 게시물이 이미 로컬 배열에 있다면?
                        if self.heartPostList[element.id] == nil {
                            // 아무것도 안함
                            self.heartPostList.updateValue(true, forKey: element.id)
                            cell.heartButton.setSymbolImage(image: "heart.fill", size: 22, color: .systemRed)
                        }
                        // 없으니 로컬 배열에 추가 후 버튼까지 활성화
                        else {
                            if self.heartPostList[element.id] == true {
                                cell.heartButton.setSymbolImage(image: "heart.fill", size: 22, color: .systemRed)
                            }
                            // 좋아요 상태가 아니라면?
                            else {
                                cell.heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
                            }
                        }
                    }
                    // 서버에서 받은 데이터에서 내가 좋아요를 하지 않은 게시물이라면?
                    else {
                        // 전역 배열 변수에 해당 게시물이 없다면?
                        if self.heartPostList[element.id] == nil {
                            // 서버도 전역변수도 모두 좋아요하지 않았으니 활성화 X
                            // 기본 좋아요 버튼 처리는 cell의 초기화와 재사용에서 처리 중
                        } else {
                            // 서버에서는 좋아요하지 않았지만 로컬에서 좋아요 클릭 후 전역 배열에 넣었다면?
                            // 좋아요 상태라면?
                            if self.heartPostList[element.id] == true {
                                cell.heartButton.setSymbolImage(image: "heart.fill", size: 22, color: .systemRed)
                            }
                            // 좋아요 상태가 아니라면?
                            else {
                                cell.heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
                            }
                        }
                    }
                    
                    if self.heartCount[element.id] == nil && self.commentCount[element.id] == nil {
                        self.heartCount.updateValue(cell.likes, forKey: element.id)
                        self.commentCount.updateValue(cell.comments, forKey: element.id)
                        cell.statusLabel.text = "\(self.commentCount[element.id]!) 답글, \(self.heartCount[element.id]!) 좋아요"
                    } else {
                        cell.statusLabel.text = "\(self.commentCount[element.id]!) 답글, \(self.heartCount[element.id]!) 좋아요"
                    }
                    
                    print("좋아요 확인: \(self.heartPostList)")
                    
                    cell.layoutIfNeeded()
                    self.userTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
                
                cell.moreButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _ in
                        owner.presentPostBottomSheet(value: true, id: element.id)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.heartButton.rx.tap
                    .withUnretained(self)
                    .flatMap { owner, _ in
                        owner.repository.requestLike(id: element.id)
                    }
                    .withUnretained(self)
                    .subscribe(onNext: { owner, result in
                        switch result {
                        case .success(let data):
                            print("좋아요 상태 \(data.likeStatus)")
                            
                            guard let count = owner.heartCount[element.id] else { return }
                            
                            // 좋아요 API 호출 후 true면?
                            if data.likeStatus {
                                // 로컬 배열에 추가 후 버튼 활성화
                                owner.heartPostList.updateValue(true, forKey: element.id)
                                
                                owner.heartCount.updateValue(count + 1, forKey: element.id)
                                cell.statusLabel.text = "\(owner.commentCount[element.id]!) 답글, \(owner.heartCount[element.id]!) 좋아요"
                                
                                print("좋아요 확인: \(owner.heartPostList)")
                                cell.heartButton.setSymbolImage(image: "heart.fill", size: 22, color: .systemRed)
                            }
                            // 좋아요 API 호출 후 false?
                            else {
                                // 로컬 배열에서 삭제해야하기 때문에 id 있는지 확인
                                if owner.heartPostList.keys.contains(element.id) {
                                    // 값을 지우는 것이 아닌 false처리
                                    owner.heartPostList.updateValue(false, forKey: element.id)
                                    
                                    owner.heartCount.updateValue(count - 1, forKey: element.id)
                                    cell.statusLabel.text = "\(owner.commentCount[element.id]!) 답글, \(owner.heartCount[element.id]!) 좋아요"
                                    
                                    print("좋아요 확인: \(owner.heartPostList)")
                                    cell.heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
                                }
                                // 로컬 배열에 id가 없다면?
                                else {
                                    print("좋아요 전역변수에 해당 게시글의 id가 없습니다. 확인해주세요.")
                                }
                            }
                            
                        case .failure(let error):
                            guard let likeError = LikeError(rawValue: error.rawValue) else {
                                print("좋아요 실패.. \(error.message)")
                                return
                            }
                            print("커스텀 좋아요 에러 \(likeError.message)")
                        }
                    })
                    .disposed(by: cell.disposeBag)
    
                cell.commentButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _ in
                        owner.commentViewController(item: element, row: row, id: element.id)
                    }
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        output.refreshLoading
            .withUnretained(self)
            .bind { owner, value in
                if value {
                    UIView.setAnimationsEnabled(false)
                    owner.userTableView.beginUpdates()
                    owner.userTableView.refreshControl?.endRefreshing()
                    owner.userTableView.layoutIfNeeded()
                    owner.userTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    
                    owner.heartPostList = [:]
                    owner.heartCount = [:]
                    owner.commentCount = [:]
                }
            }
            .disposed(by: disposeBag)
        
        // zip으로 해당 cell의 index와 model을 모두 가져오자.
        // 수업에서 배운 부분!
        Observable.zip(userTableView.rx.modelSelected(PostResponse.self), userTableView.rx.itemSelected)
            .withUnretained(self)
            .bind { owner, value in
                owner.nextDetailViewController(item: value.0, row: value.1.row, id: value.0.id)
            }
            .disposed(by: disposeBag)
    
        userTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    //MARK: protocol method
    func sendData(data: Void) {
        self.sendData = ()
        self.userTableView.layoutIfNeeded()
    }
    
    func reloadHeart(row: Int, id: String, status: Bool) {
        self.userTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
        // 홈 vc로 돌아왔을 때 데이터를 갱신하지 말고
        // id 값을 이용하여 딕셔너리에 의존
        if status {
            self.heartPostList[id] = true
            let count = self.heartCount[id]
            self.heartCount[id] = count! + 1
        } else {
            self.heartPostList[id] = false
            let count = self.heartCount[id]
            self.heartCount[id] = count! - 1
        }
        // reloadRows를 까먹고 있었다..
        // 역시 ChatG선생.... good
        self.userTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        
    }
    
    func reloadAddComment(row: Int, id: String) {
        self.userTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
        guard let count = self.commentCount[id] else { return }
        self.commentCount[id] = count + 1
        
        self.userTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        
    }
    
    func reloadSubComment(row: Int, id: String) {
        self.userTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
        guard let count = self.commentCount[id] else { return }
        self.commentCount[id] = count - 1
        
        self.userTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
    
    private func commentViewController(item: PostResponse, row: Int, id: String) {
        let vc = CommentViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        
        vc.post = item
        vc.row = row
        vc.postID = id
        vc.sendDelegate = self
        vc.scrollDelegate = self
        
        self.present(nav, animated: true)
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.backBarButtonItem = backBarbutton
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
    
    private func nextDetailViewController(item: PostResponse, row: Int, id: String) {
        let vc = HomeDetailViewController()
        vc.item = item
        vc.homeRow = row
        vc.postID = id
        
        vc.sendDelegate = self
        vc.scrollDelegate = self

        self.navigationController?.pushViewController(vc, animated: true)
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
    
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserProfileTableHeaderView.identifier) as? UserProfileTableHeaderView, let userID else { return UIView() }
        
        header.test(viewModel)
        
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
//                    owner.followButtonStatus = ()
                    owner.observeData.accept(())
                    
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
//                    owner.followButtonStatus = ()
                    owner.observeData.accept(())
                    
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
}

extension UserProfileViewController: UISheetPresentationControllerDelegate {
    
}
