//
//  SearchViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    
    private lazy var searchController = {
        let view = UISearchController(searchResultsController: nil)
        view.searchBar.delegate = self
        return view
    }()
    
    private var searchTableView = {
        let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        return view
    }()

    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        
    }
    
    func bind() {
        let contents = [
            SearchList(profileImage: "basicUser", userID: "300_r_h", userName: "홍길동", follower: "팔로워 120명"),
            SearchList(profileImage: "basicUser", userID: "looksy_rh", userName: "홍길동", follower: "팔로워 530명"),
            SearchList(profileImage: "basicUser", userID: "jhyeong___", userName: "홍길동", follower: "팔로워 1,206명"),
            SearchList(profileImage: "basicUser", userID: "km._.kang", userName: "홍길동", follower: "팔로워 301명"),
            SearchList(profileImage: "basicUser", userID: "190_po", userName: "홍길동", follower: "팔로워 786명"),
            SearchList(profileImage: "basicUser", userID: "strong_0_7", userName: "홍길동", follower: "팔로워 1.2만명"),
            SearchList(profileImage: "basicUser", userID: "today_12", userName: "홍길동", follower: "팔로워 2,673명"),
            SearchList(profileImage: "basicUser", userID: "ho_o_n", userName: "홍길동", follower: "팔로워 3만명")
        ]
        
        Observable.just(contents)
            .bind(to: searchTableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
             
                cell.profileImageView.image = UIImage(named: element.profileImage)
                cell.userIDLabel.text = element.userID
                cell.userNameLabel.text = element.userName
                cell.followerLabel.text = element.follower
                cell.selectionStyle = .none
                
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.tintColor = .black
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "검색"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationController?.navigationBar.backgroundColor = .systemBackground
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationItem.largeTitleDisplayMode = .inline
    }
    
    override func configureView() {
        super.configureView()
        
        [searchTableView].forEach {
            view.addSubview($0)
        }
        
    }

    override func setConstraints() {
        super.setConstraints()
        
        searchTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}
