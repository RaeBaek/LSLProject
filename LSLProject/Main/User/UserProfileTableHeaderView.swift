//
//  UserProfileTableHeaderView.swift
//  LSLProject
//
//  Created by 백래훈 on 12/11/23.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

final class UserProfileTableHeaderView: BaseTableViewHeaderFotterView {
    
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
    
    let followButton = FollowButton(frame: .zero)
    let mentionButton = FollowButton(frame: .zero)
    
    private let repository = NetworkRepository()
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        
    }
    
    func test(_ viewModel: UserProfileViewModel) {
        
//        let userProfile = PublishRelay<Bool>()
//        let myProfile = PublishRelay<Bool>()
        
        viewModel.userProfile
            .withUnretained(self)
            .bind { owner, value in
                owner.emailLabel.text = value.nick
                owner.nickNameLabel.text = value.nick
                owner.followerLabel.text = "팔로워 \(value.followers.count)명"
                
//                if value.following.map({ $0.id }).contains(UserDefaultsManager.id) {
//                    userProfile.accept(true)
//                } else {
//                    userProfile.accept(false)
//                }
                
                if let profileURL = value.profile {
                    let url = URL(string: APIKey.sesacURL + profileURL)
                    owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(owner.imageDownloadRequest)])
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.myProfile
            .withLatestFrom(viewModel.userID, resultSelector: { value, userID in
                return (value, userID)
            })
            .withUnretained(self)
            .bind { owner, result in
//                if result.0.following.map({ $0.id }).contains(result.1) {
//                    myProfile.accept(true)
//                } else {
//                    myProfile.accept(false)
//                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.myFollowStatus, viewModel.userFollowStatus)
            .withUnretained(self)
            .bind { owner, value in
                print("ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ \(value.0) \(value.1)")
                if value.0 == true && value.1 == true {
                    owner.followButton.buttonSetting(title: "팔로잉", backgroundColor: .white, fontColor: .black, fontSize: 13, fontWeight: .semibold)
                    owner.followButton.layer.borderColor = UIColor.systemGray5.cgColor
                    owner.followButton.layer.borderWidth = 1
                    
                } else if value.0 == true && value.1 == false {
                    owner.followButton.buttonSetting(title: "팔로잉", backgroundColor: .white, fontColor: .black, fontSize: 13, fontWeight: .semibold)
                    owner.followButton.layer.borderColor = UIColor.systemGray5.cgColor
                    owner.followButton.layer.borderWidth = 1
                    
                } else if value.0 == false && value.1 == true {
                    owner.followButton.buttonSetting(title: "맞팔로우 하기", backgroundColor: .black, fontColor: .white, fontSize: 13, fontWeight: .semibold)
                    
                } else if value.0 == false && value.1 == false {
                    owner.followButton.buttonSetting(title: "팔로우", backgroundColor: .black, fontColor: .white, fontSize: 13, fontWeight: .semibold)
                    
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    func setHeaderView(sendData: BehaviorRelay<Data?>,
                       userID: BehaviorRelay<String>) {
        
        // 모델이 아닌 id값을 받아서
        // API 호출 후 보여주는 걸로
        // 231212 14:12 수정완~
//        Observable.just(id)
//            .withUnretained(self)
//            .flatMap { owner, id in
//                owner.repository.requestUserProfile(id: id)
//            }
//            .withUnretained(self)
//            .subscribe(onNext: { owner, value in
//                switch value {
//                case .success(let data):
//                    print("다른 유저 프로필 조회 성공!")
//                    
//                    
//                case .failure(let error):
//                    guard let userProfileError = UserProfileError(rawValue: error.rawValue) else {
//                        print("다른 유저 프로필 조회 실패.. \(error.message)")
//                        return
//                    }
//                    print("다른 유저 프로플 조회 에러 \(userProfileError.message)")
//                }
//            })
//            .disposed(by: disposeBag)
        
//            .withUnretained(self)
//            .bind { owner, value in
//                if let profileURL = value.profile {
//                    let url = URL(string: APIKey.sesacURL + profileURL)
//                    owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(owner.imageDownloadRequest)])
//                }
//                
//                owner.emailLabel.text = value.nick
//                owner.nickNameLabel.text = value.nick
//                print("------------------- \(value.followers)")
//                owner.followerLabel.text = "팔로워 \(value.followers.count)명"
//            }
//            .disposed(by: disposeBag)
        
        
        
//        sendData
//            .withUnretained(self)
//            .flatMapLatest { owner, _ in
//                owner.repository.requestUserProfile(id: userID.value)
//            }
//            .withUnretained(self)
//            .subscribe(onNext: { owner, value in
//                switch value {
//                case .success(let data):
//                    print("다른 유저 프로필 조회 성공!")
//                    
//                    owner.emailLabel.text = data.nick
//                    owner.nickNameLabel.text = data.nick
//                    print("------------------- \(data.followers)")
//                    owner.followerLabel.text = "팔로워 \(data.followers.count)명"
//                    
//                    if data.following.map({ $0.id }).contains(UserDefaultsManager.id) {
//                        userProfile.accept(true)
//                    } else {
//                        userProfile.accept(false)
//                    }
//                    
//                    if let profileURL = data.profile {
//                        let url = URL(string: APIKey.sesacURL + profileURL)
//                        owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(owner.imageDownloadRequest)])
//                    }
//                    
//                case .failure(let error):
//                    guard let userProfileError = UserProfileError(rawValue: error.rawValue) else {
//                        print("다른 유저 프로필 조회 실패.. \(error.message)")
//                        return
//                    }
//                    print("다른 유저 프로필 조회 에러 \(userProfileError.message)")
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        
//        
//        
//        
//        sendData
//            .withUnretained(self)
//            .flatMapLatest { owner, _ in
//                owner.repository.requestMyProfile()
//            }
//            .withUnretained(self)
//            .subscribe(onNext: { owner, value in
//                switch value {
//                case .success(let data):
//                    print("내 프로필 조회 성공!")
//                    // 내가 이미 팔로우 한 사람이라면?
//                    // 팔로잉 처리!
//                    if data.following.map({ $0.id }).contains(userID.value) {
//                        myProfile.accept(true)
//                    } else {
//                        myProfile.accept(false)
//                    }
//                case .failure(let error):
//                    guard let myProfileError = MyProfileError(rawValue: error.rawValue) else {
//                        print("내 프로필 조회 실패.. \(error.message)")
//                        return
//                    }
//                    print("내 프로필 조회 에러 \(myProfileError.message)")
//                }
//            })
//            .disposed(by: disposeBag)
        
        
        
    }
    
    override func configureView() {
        super.configureView()
        
        [emailLabel, nickNameLabel, threadsNetButton, followerLabel, profileStackView, profileImageView].forEach {
            contentView.addSubview($0)
        }
        
        [followButton, mentionButton].forEach {
            profileStackView.addArrangedSubview($0)
        }
        
        mentionButton.buttonSetting(title: "언급", backgroundColor: .white, fontColor: .black, fontSize: 13, fontWeight: .semibold)
        mentionButton.layer.borderColor = UIColor.systemGray5.cgColor
        mentionButton.layer.borderWidth = 1
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        emailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
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
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(60)
        }
        
    }
    
}
