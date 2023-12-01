//
//  HomeDetailViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import UIKit
import RxSwift
import RxCocoa

class HomeDetailViewController: BaseViewController {
    
    private let detailTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(HomeDetailPostHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeDetailPostHeaderView.identifier)
        view.register(HomeDetailCommentCell.self, forCellReuseIdentifier: HomeDetailCommentCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        return view
    }()
    
    let viewModel = HomeDetailViewModel()
    
    let disposeBag = DisposeBag()
    
    var item: PostResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        setTabBar()
        
        bind()
        
    }
    
    private func bind() {
        guard let item else { return }
        let input = HomeDetailViewModel.Input(item: BehaviorRelay(value: item))
        let output = viewModel.transform(input: input)
        
        let comments = [
            Comment(id: "1번 게시물", content: "너무 멋있어요~~", time: "2023-12-01 22:33:44",
                    creator: Creator(id: "1번 유저", nick: "sesac_user", profile: ".jpg")),
            Comment(id: "1번 게시물", content: "너무 멋있어요~~", time: "2023-12-01 22:33:44",
                    creator: Creator(id: "1번 유저", nick: "sesac_user", profile: ".jpg")),
            Comment(id: "1번 게시물", content: "너무 멋있어요~~", time: "2023-12-01 22:33:44",
                    creator: Creator(id: "1번 유저", nick: "sesac_user", profile: ".jpg")),
            Comment(id: "1번 게시물", content: "너무 멋있어요~~", time: "2023-12-01 22:33:44",
                    creator: Creator(id: "1번 유저", nick: "sesac_user", profile: ".jpg")),
            Comment(id: "1번 게시물", content: "너무 멋있어요~~", time: "2023-12-01 22:33:44",
                    creator: Creator(id: "1번 유저", nick: "sesac_user", profile: ".jpg"))
        ]
        
        Observable.just(comments)
            .bind(to: detailTableView.rx.items(cellIdentifier: HomeDetailCommentCell.identifier, cellType: HomeDetailCommentCell.self)) { (row, element, cell) in
                
                cell.loadImage(path: element.creator.profile ?? "") { data in
                    cell.profileImage.image = UIImage(data: data)
                }
                
                cell.userNickname.text = element.creator.nick
                cell.mainText.text = element.content
                
            }
            .disposed(by: disposeBag)
        
        detailTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
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
    
    override func configureView() {
        super.configureView()
        
        [detailTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        detailTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
}

extension HomeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeDetailPostHeaderView.identifier) as? HomeDetailPostHeaderView, let item else { return UIView() }
        
        header.loadImage(path: item.creator.profile ?? "") { data in
            header.profileImage.image = UIImage(data: data.value)
        }
        
        header.loadImage(path: item.image.first ?? "") { data in
            header.mainImage.image = UIImage(data: data.value)
        }
        
        header.userNickname.text = item.creator.nick
        header.mainText.text = item.title
        
        return header
    }
}
