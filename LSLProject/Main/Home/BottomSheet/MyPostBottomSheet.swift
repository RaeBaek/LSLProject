//
//  MyPostBottomSheet.swift
//  LSLProject
//
//  Created by 백래훈 on 12/9/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyPostBottomSheet: BaseViewController {
    
    let tableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        return view
    }()
    
    let dummy1 = BehaviorRelay(value: ["프로필에 고정", "답글을 남길 수 있는 사람", "좋아요 수 숨기기"])
    let dummy2 = BehaviorRelay(value: ["삭제"])
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func bind() {
        
        dummy1
            .bind(to: tableView.rx.items(cellIdentifier: UITableViewCell.identifier, cellType: UITableViewCell.self)) { row, element, cell in
                
            }
            .disposed(by: disposeBag)
        
    }
    
    override func configureView() {
        super.configureView()
        
        view.addSubview(tableView)
        
        
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
}
