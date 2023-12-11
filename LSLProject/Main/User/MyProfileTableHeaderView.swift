//
//  UserTableHeaderView.swift
//  LSLProject
//
//  Created by 백래훈 on 12/4/23.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

final class MyProfileTableHeaderView: BaseTableViewHeaderFotterView {
    
    var lockBarbutton = CustomActiveButton(frame: .zero)
    var settingBarbutton = CustomActiveButton(frame: .zero)
    
    let emailLabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = .systemFont(ofSize: 20, weight: .bold)
        return view
    }()
    
    let nickNameLabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .regular)
        return view
    }()
    
    let threadsNetButton = {
        let view = UIButton()
        var config = UIButton.Configuration.filled() //apple system button
        var titleAttr = AttributedString.init("threads.net")
        titleAttr.font = .systemFont(ofSize: 10, weight: .regular)
        
        config.baseForegroundColor = .lightGray
        config.baseBackgroundColor = .systemGray6
        config.attributedTitle = titleAttr
        
        config.cornerStyle = .capsule
        view.configuration = config
        return view
    }()
    
    let followerLabel = {
        let view = UILabel()
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()
    
    
    let profileImageView = ProfileImageView(frame: .zero)
    
    let profileStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.distribution = .fillEqually
        return view
    }()
    
    let profileEditButton = FollowButton(frame: .zero)
    let profileShareButton = FollowButton(frame: .zero)
    
    private let repository = NetworkRepository()
    
    private let disposeBag = DisposeBag()
    
    func setHeaderView(profile: PublishRelay<MyProfile>) {
        
        profile
            .withUnretained(self)
            .bind { owner, value in
                if let profileURL = value.profile {
                    let url = URL(string: APIKey.sesacURL + profileURL)
                    owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(owner.imageDownloadRequest)])
                }
                
                owner.emailLabel.text = value.email
                owner.nickNameLabel.text = value.nick
                owner.followerLabel.text = "팔로워 \(value.followers.count)명"
            }
            .disposed(by: disposeBag)
        
    }
    
    override func configureView() {
        super.configureView()
        
        [lockBarbutton, settingBarbutton, emailLabel, nickNameLabel, threadsNetButton, followerLabel, profileStackView, profileImageView].forEach {
            contentView.addSubview($0)
        }
        
        lockBarbutton.setSymbolImage(image: "lock", size: 25, color: .black)
        settingBarbutton.setSymbolImage(image: "gearshape", size: 25, color: .black)
        
        [profileEditButton, profileShareButton].forEach {
            profileStackView.addArrangedSubview($0)
        }
        
        profileEditButton.buttonSetting(title: "프로필 편집", backgroundColor: .white, fontColor: .black, fontSize: 13, fontWeight: .semibold)
        profileEditButton.layer.borderColor = UIColor.systemGray5.cgColor
        profileEditButton.layer.borderWidth = 1
        
        profileShareButton.buttonSetting(title: "프로필 공유", backgroundColor: .white, fontColor: .black, fontSize: 13, fontWeight: .semibold)
        profileShareButton.layer.borderColor = UIColor.systemGray5.cgColor
        profileShareButton.layer.borderWidth = 1
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        lockBarbutton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(25)
        }
        
        settingBarbutton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(25)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(lockBarbutton.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(16)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(12)
            $0.leading.equalTo(emailLabel)
        }
        
        threadsNetButton.snp.makeConstraints {
            $0.centerY.equalTo(nickNameLabel)
            $0.leading.equalTo(nickNameLabel.snp.trailing).offset(6)
            $0.height.equalTo(20)
        }
        
        followerLabel.snp.makeConstraints {
            $0.top.equalTo(threadsNetButton.snp.bottom).offset(20)
            $0.leading.equalTo(nickNameLabel)
        }
        
        profileStackView.snp.makeConstraints {
            $0.top.equalTo(followerLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(settingBarbutton.snp.bottom).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(60)
        }
        
    }
    
}
