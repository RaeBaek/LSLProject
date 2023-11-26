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
        let view = UITableView()
        view.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        return view
    }()
    
    private lazy var topView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let titleImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "threads")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let checkLabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 30, weight: .regular)
        return view
    }()
    
    private let withdrawButton = {
        let view = UIButton()
        view.setTitle("회원탈퇴", for: .normal)
        view.backgroundColor = .lightGray
        view.tintColor = .yellow
        return view
    }()
    
    private let viewModel = HomeViewModel(repository: NetworkRepository())
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setTabBar()
        
        bind()
        
    }
    
    private func setNavigationBar() {

        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.topItem?.titleView = titleImageView
//        navigationController?.hidesBarsOnSwipe = true
        
    }
    
    private func setTabBar() {
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()
        
        tabBarController?.tabBar.barTintColor = .white
        
    }
    
    private func bind() {
        let input = HomeViewModel.Input(withdraw: withdrawButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        let data = Observable.of([1, 2, 3, 4, 5])
        
        let posts = [
            Header(header: topView, items: [
                Post(profileImage: "우동", userNickname: "hihihi", mainText: "안녕하세요~", uploadTime: "3시간", mainImage: "달", status: "80 답글 340 좋아요"),
                Post(profileImage: "우동", userNickname: "hihihi", mainText: "안녕하세요~", uploadTime: "3시간", mainImage: "달", status: "80 답글 340 좋아요"),
                Post(profileImage: "우동", userNickname: "hihihi", mainText: "안녕하세요~", uploadTime: "3시간", mainImage: "달", status: "80 답글 340 좋아요"),
                Post(profileImage: "우동", userNickname: "hihihi", mainText: "안녕하세요~", uploadTime: "3시간", mainImage: "달", status: "80 답글 340 좋아요"),
                Post(profileImage: "우동", userNickname: "hihihi", mainText: "안녕하세요~", uploadTime: "3시간", mainImage: "달", status: "80 답글 340 좋아요")
            ])
            
        ]
        
        let dataSource = RxTableViewSectionedReloadDataSource<Header> { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
            
            if indexPath.row != 0 {
                cell.logoImageView.isHidden = true
            }
            
            cell.profileImage.image = UIImage(named: item.profileImage)
            cell.userNickname.text = item.userNickname
            cell.mainText.text = item.mainText
            cell.mainImage.image = UIImage(named: item.mainImage)
            cell.statusLabel.text = item.status
            
            cell.selectionStyle = .none
            
            return cell
            
        }
        
//        dataSource.titleForHeaderInSection = { dataSource, indexPath in
//            return "하이하이"//dataSource.sectionModels[indexPath].header
//            
//        }
        
        Observable.just(posts)
            .bind(to: homeTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        data
//            .observe(on: MainScheduler.instance)
//            .bind(to: homeTableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { (row, element, cell) in
//                
//                cell.selectionStyle = .none
//                
//            }
//            .disposed(by: disposeBag)
        
        output.check
            .withUnretained(self)
            .bind { owner, value in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
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
        
//        checkLabel.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
//        
//        withdrawButton.snp.makeConstraints {
//            $0.top.equalTo(checkLabel.snp.bottom).offset(10)
//            $0.centerX.equalToSuperview()
//            $0.size.equalTo(100)
//        }
        
    }
    
}
