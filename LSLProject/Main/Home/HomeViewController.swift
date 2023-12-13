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

final class HomeViewController: BaseViewController {
    
    private let homeTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(HomeTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeTableViewHeaderView.identifier)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.tableFooterView = UIView(frame: .zero)
        view.sectionFooterHeight = 0
        return view
    }()
    
    private lazy var backBarbutton = {
        let view = UIBarButtonItem(title: "이전", style: .plain, target: self, action: nil)
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
    
    private var model = AllPost(next: "0", limit: "10", productID: "hihi")
    
    private lazy var allPost = BehaviorRelay<AllPost>(value: model)
    
    var sendData: Void = Void() {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    lazy var observeData = BehaviorRelay(value: ())
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = HomeViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recallAllPostAPI(notification:)), name: Notification.Name("recallPostAPI"), object: nil)
        
    }
    
    @objc func recallAllPostAPI(notification: NSNotification) {
        if let data = notification.userInfo?["recallPostAPI"] as? Void {
            self.sendData = data
            // 데이터를 넘긴 후 스크롤을 해주어야 정상적으로 작동된다!!!
            self.homeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        setTabBar()
        
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
        let input = HomeViewModel.Input(sendData: observeData,
                                        userID: BehaviorRelay(value: UserDefaultsManager.id),
                                        allPost: allPost,
                                        withdraw: withdrawButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.items
            .withUnretained(self)
            .map { owner, value in
                owner.model.next = value.nextCursor
                return value.data
            }
            .bind(to: homeTableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                cell.setCell(element: element) {
                    UIView.setAnimationsEnabled(false)
                    self.homeTableView.beginUpdates()
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
                
            }
            .disposed(by: disposeBag)
        
        homeTableView.rx.modelSelected(PostResponse.self)
            .withUnretained(self)
            .bind { owner, value in
                owner.nextDetailViewController(item: value)
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
    
    private func nextDetailViewController(item: PostResponse) {
        let vc = HomeDetailViewController()
        vc.item = item

        self.navigationController?.pushViewController(vc, animated: true)
        
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
}

extension HomeViewController: UISheetPresentationControllerDelegate {
    
}
