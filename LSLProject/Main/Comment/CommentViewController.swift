//
//  CommentViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/6/23.
//

import UIKit
import RxSwift
import RxCocoa

final class CommentViewController: BaseViewController {
    
    lazy var dismissBarbutton = {
        let view = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    private let scrollView = {
        let view = UIScrollView()
        view.backgroundColor = .systemBackground
        view.isScrollEnabled = true
        return view
    }()
    
    private let contentView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let lineBar = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let myImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
        
    }
    
    override func configureView() {
        super.configureView()
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
    }
    
}
