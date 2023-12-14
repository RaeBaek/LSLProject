//
//  HeartViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

final class HeartViewController: BaseViewController {
    
    private let heartTableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        view.backgroundColor = .clear
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.refreshControl = UIRefreshControl()
        return view
    }()
    
    let repository = NetworkRepository()
    
    lazy var viewModel = HeartViewModel(repository: repository)
    
    private let disposeBag = DisposeBag()

    var sendData: Void = () {
        didSet(newValue) {
            observeData.accept(newValue)
        }
    }
    
    var observeData = BehaviorRelay(value: ())
    
    var heartPostList: [String: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        
    }
    
    func bind() {
        let input = HeartViewModel.Input(refreshing: heartTableView.refreshControl?.rx.controlEvent(.valueChanged),
                                         sendData: observeData)
        let output = viewModel.transform(input: input)
        
        output.heartPosts
            .map { $0.data }
            .bind(to: heartTableView.rx.items(cellIdentifier: PostTableViewCell.identifier, cellType: PostTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                
                cell.setCell(element: element) {
                    UIView.setAnimationsEnabled(false)
                    self.heartTableView.beginUpdates()
                    
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
                    
                    print("좋아요 확인: \(self.heartPostList)")
                    
                    cell.layoutIfNeeded()
                    self.heartTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
                
            }
            .disposed(by: disposeBag)
        
        output.refreshLoading
            .withUnretained(self)
            .bind { owner, value in
                if value {
                    owner.heartTableView.refreshControl?.endRefreshing()
                    owner.heartPostList = [:]
                }
            }
            .disposed(by: disposeBag)
        
        heartTableView.rx.modelSelected(PostResponse.self)
            .withUnretained(self)
            .bind { owner, value in
                owner.nextDetailViewController(item: value)
            }
            .disposed(by: disposeBag)
        
        heartTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        self.navigationItem.title = "좋아요"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationItem.largeTitleDisplayMode = .inline
    }
    
    private func nextDetailViewController(item: PostResponse) {
        let vc = HomeDetailViewController()
        vc.item = item

        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func configureView() {
        super.configureView()
        
        [heartTableView].forEach {
            view.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        heartTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }

}

extension HeartViewController: UITableViewDelegate {
    
}
