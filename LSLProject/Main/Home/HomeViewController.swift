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

final class HomeViewController: BaseViewController, UIScrollViewDelegate {
    
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
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = HomeViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        setTabBar()
    }
    
    private func setNavigationBar() {
        self.navigationItem.backBarButtonItem = backBarbutton
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    private func setTabBar() {
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.backgroundColor = .white
//        tabBarController?.tabBar.barTintColor = .white
        
    }
    
    private func bind() {
        let input = HomeViewModel.Input(userID: BehaviorRelay(value: UserDefaultsManager.id), 
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
                
                cell.setCell(row: row, element: element) {
                    UIView.setAnimationsEnabled(false)
                    self.homeTableView.beginUpdates()
                    cell.layoutIfNeeded()
                    self.homeTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
                
                let input = HomeViewModel.CellButtonInput(creatorID: BehaviorRelay(value: element.creator.id),
                                                          moreButtonTap: cell.moreButton.rx.tap)
                
                // 아래와 같이 전역변수 viewModel의 메서드를 사용하면 cell들이 모두 viewModel을 참조하게 되는 현상..?
                // CellViewModel을 만들어 버튼 tap event를 바인드하는 방법이 있다고는 하는데
                // 추후 시간이 있다면 개발해보자..
                // (viewModel 쪽에서 print 문이 여러번 출력되는 문제말고는 동작은 정상적으로 수행됨)
                let output = self.viewModel.buttonTransform(input: input)
//                let cellViewModel = HomeViewModel(repository: cell.repository)
                
                output.postStatus
                    .bind { value in
                        if value {
                            self.presentModalBtnTap(value: value)
                        } else {
                            self.presentModalBtnTap(value: value)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
        
        homeTableView.rx.modelSelected(PostResponse.self)
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { owner, value in
                owner.nextDetailViewController(item: value)
            }
            .disposed(by: disposeBag)
        
//        output.items
//            .bind(to: homeTableView.rx.itemSelected) -> //indexPath
        
        homeTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        output.check
            .withUnretained(self)
            .bind { owner, value in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func presentModalBtnTap(value: Bool) {
        
        let vc = PostBottomSheet()
        
        vc.modalPresentationStyle = .pageSheet
        vc.value = value
        
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
