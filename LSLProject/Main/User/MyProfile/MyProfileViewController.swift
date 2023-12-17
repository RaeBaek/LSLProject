//
//  UserViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

final class MyProfileViewController: BaseViewController, SendData, ScrollToBottom {
    
    deinit {
        print("MyProfileViewController Deinit!!")
    }
    
    private lazy var backBarbutton = {
        let view = UIBarButtonItem(title: "뒤로", style: .plain, target: self, action: nil)
        view.tintColor = .black
        return view
    }()
    
    private let myTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(MyProfileTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MyProfileTableHeaderView.identifier)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.refreshControl = UIRefreshControl()
        return view
    }()
    
    var sendData: Void = () {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    var observeData = BehaviorRelay(value: ())
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = MyProfileViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    var heartPostList: [String: Bool] = [:]
    var heartCount: [String: Int] = [:]
    var commentCount: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recallMyPostAPI(notification:)), name: Notification.Name("recallPostAPI"), object: nil)
        
        // 내 프로필 화면 -> 댓글 작성 modal 순서일 경우 delegate 패턴이 아닌 noti 활용
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
    
    private func setNavigationBar() {
        self.navigationItem.backBarButtonItem = backBarbutton
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func recallMyPostAPI(notification: NSNotification) {
        if let data = notification.userInfo?["recallPostAPI"] as? Void {
            self.sendData = data
            // 데이터를 넘긴 후 스크롤을 해주어야 정상적으로 작동된다!!!
            if myTableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
                myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
    }
    
    private func bind() {
        let input = MyProfileViewModel.Input(refreshing: myTableView.refreshControl?.rx.controlEvent(.valueChanged),
                                             sendData: observeData)
        let output = viewModel.transform(input: input)
        
        output.userPosts
            .debug("userPosts")
            .map { $0.data }
            .bind(to: myTableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                
                cell.setCell(element: element) {
                    UIView.setAnimationsEnabled(false)
                    self.myTableView.beginUpdates()
                    
                    // 일반 배열에서 딕셔너리로 수정하였고
                    // 딕셔너리는 중복이 안되므로 고유한 id의 정보를 저장하기에 적합하며
                    // 서버에서 받아온 데이터 중에서 좋아요가 되어있는 게시물이라면
                    // 처음에는 무조건 딕셔너리에 추가된다.
                    // 이후 좋아요를 취소하면 좋아요 취소 api를 호출하는데 여기서 전체 데이터를 갱신하는게 아닌
                    // 딕셔너리의 해당하는 id의 value 값을 변경하는 것이다.
                    // 이로써 데이터가 갱신되기 전에는 로컬 딕셔너리를 참조하면서
                    // 좋아요 처리를 수행할 수 있다.
                    // 유저프로필 화면과 홈화면에 코드 옮길 것!!!!
                    
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
                    
                    print("댓글 확인: \(self.commentCount)")
                    print("좋아요 확인: \(self.heartPostList)")
                    
                    cell.layoutIfNeeded()
                    self.myTableView.endUpdates()
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
                    owner.myTableView.beginUpdates()
                    owner.myTableView.refreshControl?.endRefreshing()
                    owner.myTableView.layoutIfNeeded()
                    owner.myTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    
                    owner.heartPostList = [:]
                    owner.heartCount = [:]
                    owner.commentCount = [:]
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(myTableView.rx.modelSelected(PostResponse.self), myTableView.rx.itemSelected)
            .withUnretained(self)
            .bind { owner, value in
                owner.nextDetailViewController(item: value.0, row: value.1.row, id: value.0.id)
            }
            .disposed(by: disposeBag)
        
        myTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
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
    
    private func presentSettingSheet() {
        let vc = ExitBottomSheet()
        
        vc.modalPresentationStyle = .pageSheet
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in
                    return 150
                }
            ]
            
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
        }
        
        self.present(vc, animated: true)
    }
    
    private func nextDetailViewController(item: PostResponse, row: Int, id: String) {
        let vc = HomeDetailViewController()
        
        vc.item = item
        vc.homeRow = row
        vc.postID = id
        
        vc.scrollDelegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func sendData(data: Void) {
        sendData = data
        self.myTableView.layoutIfNeeded()
    }
    
    func reloadHeart(row: Int, id: String, status: Bool) {
        self.myTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
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
        self.myTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        
    }
    
    func reloadAddComment(row: Int, id: String) {
        self.myTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
        guard let count = self.commentCount[id] else { return }
        self.commentCount[id] = count + 1
        
        self.myTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        
    }
    
    func reloadSubComment(row: Int, id: String) {
        self.myTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        
        guard let count = self.commentCount[id] else { return }
        self.commentCount[id] = count - 1
        
        self.myTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
    
    override func configureView() {
        super.configureView()
        
        [myTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        myTableView.snp.makeConstraints {
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
        
        header.settingBarbutton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.presentSettingSheet()
            }
            .disposed(by: header.disposeBag)
        
        header.profileEditButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.presentProfileEdit()
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

extension MyProfileViewController: UISheetPresentationControllerDelegate {
    
}
