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

final class UserTableHeaderView: UITableViewHeaderFooterView {
    
    let emailLabel = {
        let view = UILabel()
        view.text = "raebaek@naver.com"
        view.textColor = .black
        view.font = .systemFont(ofSize: 20, weight: .bold)
        return view
    }()
    
    let nickNameLabel = {
        let view = UILabel()
        view.text = "100_r_h"
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
        view.text = "팔로우 111명"
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()
    
    
    let profileImageView = {
        let view = ProfileImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let profileStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.distribution = .fillEqually
        return view
    }()
    
    let profileEditButton = {
        let view = UIButton()
        
        var config = UIButton.Configuration.plain() //apple system button
        var titleAttr = AttributedString.init("프로필 편집")
        titleAttr.font = .systemFont(ofSize: 13, weight: .semibold)
        
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        config.attributedTitle = titleAttr
        
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        
        view.configuration = config
        return view
    }()
    
    let profileShareButton = {
        let view = UIButton()
        
        var config = UIButton.Configuration.plain() //apple system button
        var titleAttr = AttributedString.init("프로필 공유")
        titleAttr.font = .systemFont(ofSize: 13, weight: .semibold)
        
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        config.attributedTitle = titleAttr
        
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        
        view.configuration = config
        return view
    }()
    
    private let repository = NetworkRepository()
    
    private let disposeBag = DisposeBag()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHeaderView(profile: PublishRelay<MyProfile>) {
        
        profile
            .withUnretained(self)
            .bind { owner, value in
                let url = URL(string: APIKey.sesacURL + (value.profile ?? ""))
                
                let imageDownloadRequest = AnyModifier { request in
                    var requestBody = request
                    requestBody.setValue(UserDefaultsManager.token, forHTTPHeaderField: "Authorization")
                    requestBody.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
                    return requestBody
                }
                
                owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(imageDownloadRequest)])
                
                owner.emailLabel.text = value.email
                owner.nickNameLabel.text = value.nick
                owner.followerLabel.text = "팔로워 \(value.followers.count)명"
            }
            .disposed(by: disposeBag)
        
    }
    
    func configureView() {
        [emailLabel, nickNameLabel, threadsNetButton, followerLabel, profileStackView, profileImageView].forEach {
            contentView.addSubview($0)
        }
        
        [profileEditButton, profileShareButton].forEach {
            profileStackView.addArrangedSubview($0)
        }
        
    }
    
    func setConstraints() {
        
        emailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
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
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(70)
        }
        
        
    }
    
}
