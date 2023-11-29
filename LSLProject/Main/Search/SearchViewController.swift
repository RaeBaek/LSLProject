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
    
    func bind() {
        let contents = [
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명"),
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명"),
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명"),
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명"),
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명"),
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명"),
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명"),
            SearchList(profileImage: "우동", userID: "100_r_h", userName: "백래훈", follower: "팔로워 100명")
        ]
        
        Observable.just(contents)
            .bind(to: searchTableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
             
                cell.profileImageView.image = UIImage(named: element.profileImage)
                cell.userIDLabel.text = element.userID
                cell.userNameLabel.text = element.userName
                cell.followerLabel.text = element.follower
                
            }
            .disposed(by: disposeBag)
        
        
    }
    
    override func configureView() {
        super.configureView()
        
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.tintColor = .black
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "검색"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.hidesBarsOnSwipe = true
//        self.navigationController?.navigationBar.isHidden = true
        
//        searchTableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: false)
//        self.navigationController?.navigationBar.sizeToFit()
        
        
        [searchTableView].forEach {
            view.addSubview($0)
        }
        
        
    }

    override func setConstraints() {
        super.setConstraints()
        
        searchTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}
