//
//  SettingBottomSheet.swift
//  LSLProject
//
//  Created by 백래훈 on 12/17/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class ExitBottomSheet: BaseViewController {
    
    let tableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        view.rowHeight = 50
        view.isScrollEnabled = false
        return view
    }()
    
    var exit = [
        Header(header: nil,
               items: [
                Bottom(title: "프로필에 고정", color: .black),
                Bottom(title: "답글을 남길 수 있는 사람", color: .black),
                Bottom(title: "좋아요 수 숨기기", color: .black)
        ]),
        Header(header: nil,
               items: [
                Bottom(title: "삭제", color: .systemRed)
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
