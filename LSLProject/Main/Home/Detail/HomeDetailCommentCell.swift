//
//  HomeDetailCommentCell.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class HomeDetailCommentCell: BaseTableViewCell {
    
    override func prepareForReuse() {
        profileImage.image = UIImage(named: "basicUser")
        disposeBag = DisposeBag()
    }
    
    private let topLine = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    var profileImage = ProfileImageView(frame: .zero)
    
    var userNickname = NicknameLabel(frame: .zero)
    
    var uploadTime = UploadTimeLabel(frame: .zero)
    
    var moreButton = MoreButton(frame: .zero)
    
    var mainText = MainTitle(frame: .zero)
    
    private let heartButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "heart", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    private let commentButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "message", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    private let repostButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "repeat", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    private let dmButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
        let image = UIImage(systemName: "paperplane", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    private let repository = NetworkRepository()
    
    var disposeBag = DisposeBag()
    
    func setCell(element: Comment, completion: @escaping () -> ()) {
        
        if let profile = element.creator.profile {
            let profileImageUrl = URL(string: APIKey.sesacURL + profile)
            profileImage.kf.setImage(with: profileImageUrl, options: [.requestModifier(imageDownloadRequest)])
            
        }
        
        userNickname.text = element.creator.nick
        mainText.text = element.content
        uploadTime.text = self.timeAgoSinceDate(element.time)
        
        completion()
        
    }
    
    func loadImage(path: String, completion: @escaping (Data) -> Void) {
        
        let result = BehaviorRelay(value: Data())
        
        Observable.of(())
            .observe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.repository.requestImage(path: path)
            }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    result.accept(data)
                    completion(data)
                case .failure(let error):
                    print(error.message)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    override func configureCell() {
        super.configureCell()
        
        [topLine, profileImage, userNickname, mainText, uploadTime, moreButton, heartButton, commentButton, repostButton, dmButton].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        topLine.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        profileImage.snp.makeConstraints {
            $0.top.equalTo(topLine.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(38)
        }
        
        userNickname.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(profileImage.snp.trailing).offset(12)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(userNickname.snp.centerY)
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(22)
        }
        
        uploadTime.snp.makeConstraints {
            $0.centerY.equalTo(moreButton.snp.centerY)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-12)
        }
        
        mainText.snp.makeConstraints {
            $0.top.equalTo(userNickname.snp.bottom).offset(6)
            $0.leading.equalTo(userNickname.snp.leading)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        heartButton.snp.makeConstraints {
            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.leading.equalTo(mainText.snp.leading)
            $0.size.equalTo(22)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        commentButton.snp.makeConstraints {
            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.leading.equalTo(heartButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        repostButton.snp.makeConstraints {
            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.leading.equalTo(commentButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        dmButton.snp.makeConstraints {
            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.leading.equalTo(repostButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
    }
    
}
