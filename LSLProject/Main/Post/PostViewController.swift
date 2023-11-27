//
//  PostViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit

final class PostViewController: BaseViewController {

    lazy var dismissBarbutton = {
        let view = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    lazy var moreBarbutton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        
    }
    
    private func setNavigationBar() {
        title = "새로운 스레드"
        
        self.navigationItem.leftBarButtonItem = dismissBarbutton
        self.navigationItem.rightBarButtonItem = moreBarbutton
        
        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
//        self.navigationController?.navigationBar.backgroundColor = .systemGray
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
