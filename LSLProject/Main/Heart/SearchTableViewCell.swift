//
//  SearchTableViewCell.swift
//  LSLProject
//
//  Created by 백래훈 on 11/29/23.
//

import UIKit

class SearchTableViewCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: SearchTableViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var profileImageView = ProfileImageView(frame: .zero)
    
    let userIDLabel = {
        let view = UILabel()
        view.text = "100_r_h"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .semibold)
        return view
    }()
    
    let userNameLabel = {
        let view = UILabel()
        view.text = "백래훈"
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()
    
    let followerLabel = {
        let view = UILabel()
        view.text = "팔로워 100명"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()
    
    let followButton = {
        let view = UIButton()
        
        var config = UIButton.Configuration.plain() //apple system button
        
        var titleAttr = AttributedString.init("팔로우")
        titleAttr.font = .systemFont(ofSize: 15, weight: .semibold)
        
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .yellow
        config.attributedTitle = titleAttr
        
        view.configuration = config
        
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let lineView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func configureCell() {
        super.configureCell()
        
        [profileImageView, userIDLabel, userNameLabel, followerLabel, followButton, lineView].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(38)
        }
        
        userIDLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(userIDLabel.snp.bottom).offset(10)
            $0.leading.equalTo(userIDLabel.snp.leading)
        }
        
        followerLabel.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(12)
            $0.leading.equalTo(userNameLabel.snp.leading)
        }
        
        lineView.snp.makeConstraints {
            $0.top.equalTo(followerLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(70)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }
        
        followButton.snp.makeConstraints {
            $0.top.equalTo(userIDLabel.snp.top)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(100)
            $0.height.equalTo(30)
        }
        
    }
    
}
