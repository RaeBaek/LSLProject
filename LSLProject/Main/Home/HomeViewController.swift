//
//  HomeViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/19/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol ScrollToBottom {
    func reloadHeart(row: Int, id: String, status: Bool)
    func reloadAddComment(row: Int, id: String)
    func reloadSubComment(row: Int, id: String)
}

final class HomeViewController: BaseViewController, SendData, ScrollToBottom {
    
    private let homeTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(HomeTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeTableViewHeaderView.identifier)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.refreshControl = UIRefreshControl()
        return view
    }()
    
    private lazy var backBarbutton = {
        let view = UIBarButtonItem(title: "뒤로", style: .plain, target: self, action: nil)
        view.tintColor = .black
        return view
    }()
    
    private let withdrawButton = {
        let view = UIButton()
        view.setTitle("회원탈퇴", for: .normal)
        view.backgroundColor = .lightGray
        view.tintColor = .yellow
        return view
    }()
    
    var sendData: Void = Void() {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    lazy var observeData = BehaviorRelay(value: ())
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = HomeViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    var heartPostList: [String: Bool] = [:]
    var heartCount: [String: Int] = [:]
    var commentCount: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recallAllPostAPI(notification:)), name: Notification.Name("recallPostAPI"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("좋아요 리스트 \(heartPostList)")
        setNavigationBar()
        setTabBar()
        
        // 화면을 다시 그려줘야 cell이 깨지지 않음!
        self.view.layoutIfNeeded()
//        self.homeTableView.layoutIfNeeded()
//        self.homeTableView.
        
    }
    
    @objc func recallAllPostAPI(notification: NSNotification) {
        if let data = notification.userInfo?["recallPostAPI"] as? Void {
            self.sendData = data
            // 데이터를 넘긴 후 스크롤을 해주어야 정상적으로 작동된다!!!
//            if homeTableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
//                homeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//            }
        }
    }
    
    private func setNavigationBar() {
        self.navigationItem.backBarButtonItem = backBarbutton
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    private func setTabBar() {
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.backgroundColor = .white
//        tabBarController?.tabBar.barTintColor = .white
        
    }
    
    private func bind() {
        let input = HomeViewModel.Input(refreshing: homeTableView.refreshControl?.rx.controlEvent(.valueChanged),
                                        sendData: observeData,
                                        userID: BehaviorRelay(value: UserDefaultsManager.id),
                                        withdraw: withdrawButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.items
            .map { $0.data }
            .bind(to: homeTableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                cell.setCell(element: element) {
                    UIView.setAnimationsEnabled(false)
                    self.homeTableView.beginUpdates()
                    
                    // 먼저 서버에서 받은 데이터에서 내가 좋아요 한 게시물이라면?
                    if element.likes.contains(UserDefaultsManager.id) {
                        // 좋아요 한 게시물이 이미 로컬 배열에 있다면?
                        if self.heartPostList[element.id] == nil {
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
//                            cell.heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
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
                    
//                    if self.commnetCount[element.id] == nil {
//                        
//                    }
                    
                    print("좋아요 확인: \(self.heartPostList)")
                    
                    cell.layoutIfNeeded()
                    self.homeTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
                
                cell.moreButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _ in
                        if element.creator.id == UserDefaultsManager.id {
                            owner.presentPostBottomSheet(value: true, id: element.id)
                        } else {
                            owner.presentPostBottomSheet(value: false, id: element.id)
                        }
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
                            
                            cell.layoutIfNeeded()
                            
                        case .failure(let error):
                            guard let likeError = LikeError(rawValue: error.rawValue) else {
                                print("좋아요 실패.. \(error.message)")
                                return
                            }
                            print("커스텀 좋아요 에러 \(likeError.message)")
                        }
                        
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.profileImageButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _ in
                        if element.creator.id == UserDefaultsManager.id {
                            return
                        } else {
                            owner.presentUserProfileViewController(id: element.creator.id)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.commentButton.rx.tap
                    .withUnretained(self)
                    .bind { owner, _ in
                        owner.commentViewController(item: element)
                    }
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        output.refreshLoading
            .withUnretained(self)
            .bind { owner, value in
                if value {
                    UIView.setAnimationsEnabled(false)
                    owner.homeTableView.beginUpdates()
                    owner.homeTableView.refreshControl?.endRefreshing()
                    owner.homeTableView.layoutIfNeeded()
                    owner.homeTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    
                    owner.heartPostList = [:]
                    owner.heartCount = [:]
                    owner.commentCount = [:]
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(homeTableView.rx.modelSelected(PostResponse.self), homeTableView.rx.itemSelected)
            .withUnretained(self)
            .bind { owner, value in
                owner.nextDetailViewController(item: value.0, row: value.1.row, id: value.0.id)
            }
            .disposed(by: disposeBag)
        
        homeTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        output.check
            .withUnretained(self)
            .bind { owner, value in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    func sendData(data: Void) {
        self.sendData = ()
//        self.view.layoutIfNeeded()
        self.homeTableView.layoutIfNeeded()
        
//        UIView.setAnimationsEnabled(false)
//        self.homeTableView.beginUpdates()
//        self.homeTableView.layoutIfNeeded()
//        self.homeTableView.endUpdates()
//        UIView.setAnimationsEnabled(true)
    }
    
    func reloadHeart(row: Int, id: String, status: Bool) {
        self.homeTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
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
        self.homeTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        
    }
    
    func reloadAddComment(row: Int, id: String) {
        self.homeTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
        let count = self.commentCount[id]
        self.commentCount[id] = count! + 1
        
        self.homeTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        
    }
    
    func reloadSubComment(row: Int, id: String) {
        self.homeTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
        let count = self.commentCount[id]
        self.commentCount[id] = count! - 1
        
        self.homeTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
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
    
    private func presentUserProfileViewController(id: String) {
        let vc = UserProfileViewController()
        vc.userID = id
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func nextDetailViewController(item: PostResponse, row: Int, id: String) {
        let vc = HomeDetailViewController()
        vc.item = item
        vc.row = row
        vc.postID = id
        vc.sendDelegate = self
        vc.scrollDelegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func commentViewController(item: PostResponse) {
        let vc = CommentViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        
        vc.post = item
        vc.sendDelegate = self
        
        self.present(nav, animated: true)
    }
    
    private func changeRootViewController() {
        let vc = SignInViewController()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc)
        
    }
    
    override func configureView() {
        super.configureView()
        
        [homeTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
//        homeTableView.tableHeaderView?.snp.makeConstraints {
//            $0.height.equalTo(40)
//        }
        
        homeTableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(59)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeaderView.identifier) as? HomeTableViewHeaderView else { return UIView() }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
}

extension HomeViewController: UISheetPresentationControllerDelegate {
    
}
