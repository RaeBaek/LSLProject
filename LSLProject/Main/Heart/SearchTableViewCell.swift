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
    
    
    lazy var profileImageView = {
        let view = ProfileImageView(frame: .zero)
        view.contentMode = .scaleToFill
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
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
        view.textColor = .darkGray
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
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.setTitle("팔로우", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()
    
    override func configureCell() {
        super.configureCell()
        
        [profileImageView, userIDLabel, userNameLabel, followerLabel, followButton].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(30)
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
            $0.top.equalTo(userNameLabel.snp.bottom).offset(16)
            $0.leading.equalTo(userNameLabel.snp.leading)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        followButton.snp.makeConstraints {
            $0.top.equalTo(userIDLabel.snp.top)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
        }
        
    }
    
}
