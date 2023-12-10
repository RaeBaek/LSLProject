//
//  UserProfileViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/10/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class UserProfileViewController: BaseViewController {
    
    // 다른 유저 프로필 상세화면 구현하기
    // 내 프로필 상세화면과 매우 유사
    lazy var moreBarbutton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: nil)
        view.tintColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.rightBarButtonItem = moreBarbutton
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
    
    
}
