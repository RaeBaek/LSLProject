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
        view.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        view.register(HomeTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeTableViewHeaderView.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
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
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    private func setTabBar() {
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
        
        tabBarController?.tabBar.barTintColor = .white
        
    }
    
    private func bind() {
        let input = HomeViewModel.Input(userID: BehaviorRelay(value: UserDefaultsManager.id), allPost: allPost, withdraw: withdrawButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.items
            .withUnretained(self)
            .map { value in
                self.model.next = value.1.nextCursor
                return value.1.data
            }
            .bind(to: homeTableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { [weak self] (row, element, cell) in
                
                guard let self else { return }
                
                cell.userNickname.text = element.creator.nick
                cell.mainText.text = element.title
                
                print("이미지 주소: \(element.image.first ?? "")")
                
                cell.mainImage.image = UIImage(data: self.loadImageAPI(path: element.image.first ?? ""))
                
                cell.statusLabel.text = element.productID
                cell.profileImage.image = UIImage(named: element.creator.profile ?? "")
                
                cell.selectionStyle = .none
                
            }
            .disposed(by: disposeBag)
        
        homeTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        output.check
            .withUnretained(self)
            .bind { owner, value in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func loadImageAPI(path: String) -> Data {
        
        var result = Data()
        
        Observable.just(())
            .observe(on: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { self.repository.reqeustDownloadImage(path: path) }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    result = data.image
                case .failure(let error):
                    print(error.message)
                }
            })
            .disposed(by: disposeBag)
        
        return result
    }
    
    private func changeRootViewController() {
        let vc = SignInViewController()
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(vc)
        
    }
    
    override func configureView() {
        super.configureView()
        
        view.backgroundColor = .systemBackground
        
        [homeTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
//        topView.snp.makeConstraints {
//            $0.top.horizontalEdges.equalToSuperview()
//            $0.
//        }
        
        
        homeTableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(59)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
//            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        homeTableView.tableHeaderView?.snp.makeConstraints {
            $0.height.equalTo(35)
        }
        
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableViewHeaderView.identifier) as? HomeTableViewHeaderView else { return UIView() }
        
        
        return header
    }
}
