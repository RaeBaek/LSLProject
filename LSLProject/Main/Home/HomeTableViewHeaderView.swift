//
//  HomeTableViewHeaderView.swift
//  LSLProject
//
//  Created by 백래훈 on 11/27/23.
//

import UIKit
import SnapKit

final class HomeTableViewHeaderView: UITableViewHeaderFooterView {
    
    let logoImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "threads")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        contentView.addSubview(logoImageView)
    }
    
    func setConstraints() {
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(5)
            $0.width.equalTo(35)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-5)
        }
    }
    
    
}
