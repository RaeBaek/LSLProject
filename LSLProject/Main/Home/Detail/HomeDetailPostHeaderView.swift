//
//  HomeDetailPostCell.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

final class HomeDetailPostHeaderView: BaseTableViewHeaderFotterView {
    
    lazy var profileImage = ProfileImageView(frame: .zero)
    
    var userNickname = NicknameLabel(frame: .zero)
    var uploadTime = UploadTimeLabel(frame: .zero)
    let moreButton = MoreButton(frame: .zero)
    var mainText = MainTitle(frame: .zero)
    var mainImage = MainImageView(frame: .zero)
    
    private let lineBar = CustomLineBar(frame: .zero)
    
    let heartButton = CustomActiveButton(frame: .zero)
    let commentButton = CustomActiveButton(frame: .zero)
    private let repostButton = CustomActiveButton(frame: .zero)
    private let dmButton = CustomActiveButton(frame: .zero)
    
    var statusLabel = {
        let view = UILabel()
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 13, weight: .regular)
        return view
    }()
    
    var disposeBag = DisposeBag()
    
//    var item: PostResponse?
    var item = PublishRelay<PostResponse>()
    var postID: String?
    
    private let repository = NetworkRepository()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        
        guard let postID else { return }
        
        Observable.just(postID)
            .withUnretained(self)
            .flatMap { owner, id in
                return owner.repository.requestAPost(id: id)
            }
            .withUnretained(self)
            .subscribe(onNext: { owner, result in
                switch result {
                case .success(let data):
                    print("해당 게시물 조회 성공!")
                    owner.item.accept(data)
                    
                case .failure(let error):
                    guard let allPostError = AllPostError(rawValue: error.rawValue) else {
                        print("해당 게시물 조회 실패.. \(error.message)")
                        return
                    }
                    print("커스텀 해당 게시물 에러 \(allPostError.message)")
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func test(_ viewModel: HomeDetailViewModel) {
        viewModel.item
            .withUnretained(self)
            .bind { owner, item in
                owner.item.accept(item)
            }
            .disposed(by: disposeBag)
    }
    
    func setHeaderView(completion: @escaping () -> ()) {
//        guard let item else { return }
        
        item
            .withUnretained(self)
            .bind { owner, item in
                
                if item.likes.contains(UserDefaultsManager.id) {
                    owner.heartButton.setSymbolImage(image: "heart.fill", size: 22, color: .systemRed)
                } else {
                    owner.heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
                }
                
                owner.statusLabel.text = "\(item.comments.count) 답글, \(item.likes.count) 좋아요"
                owner.uploadTime.text = self.timeAgoSinceDate(item.time)
                
                if let profileURL = item.creator.profile {
                    let url = URL(string: APIKey.sesacURL + profileURL)
                    owner.profileImage.kf.setImage(with: url, options: [.requestModifier(owner.imageDownloadRequest)])
                }
                
                owner.userNickname.text = item.creator.nick
                
                if item.title != "" {
                    self.mainText.text = item.title
                    
                    if let image = item.image.first {
                        owner.loadImage(path: image) { [weak self] data in
                            guard let self else { return }
                            
                            DispatchQueue.main.async {
                                self.setImage(data: data.value) { data in
                                    
                                    self.mainText.snp.remakeConstraints {
                                        $0.top.equalTo(self.profileImage.snp.bottom).offset(12)
                                        $0.horizontalEdges.equalToSuperview().inset(12)
                                    }
                                    
                                    self.mainImage.snp.remakeConstraints {
                                        $0.top.equalTo(self.mainText.snp.bottom).offset(12)
                                        $0.horizontalEdges.equalToSuperview().inset(12)
                                        $0.height.equalTo(data).priority(999)
                                    }
                                    
                                    self.heartButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.mainImage.snp.bottom).offset(12)
                                        $0.leading.equalTo(self.mainImage)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.commentButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton)
                                        $0.leading.equalTo(self.heartButton.snp.trailing).offset(12)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.repostButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton)
                                        $0.leading.equalTo(self.commentButton.snp.trailing).offset(12)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.dmButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton)
                                        $0.leading.equalTo(self.repostButton.snp.trailing).offset(12)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.statusLabel.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton.snp.bottom).offset(12)
                                        $0.leading.equalTo(self.heartButton)
                                        $0.bottom.equalToSuperview().offset(-12)
                                    }
                                    completion()
                                }
                            }
                        }
                    } else {
                        owner.mainText.snp.remakeConstraints {
                            $0.top.equalTo(owner.profileImage.snp.bottom).offset(12)
                            $0.horizontalEdges.equalToSuperview().inset(12)
                        }
                        
                        owner.mainImage.snp.removeConstraints()
                        
                        owner.heartButton.snp.remakeConstraints {
                            $0.top.equalTo(owner.mainText.snp.bottom).offset(12)
                            $0.leading.equalTo(owner.mainText)
                            $0.size.equalTo(22)
                        }
                        
                        owner.commentButton.snp.remakeConstraints {
                            $0.top.equalTo(owner.heartButton)
                            $0.leading.equalTo(owner.heartButton.snp.trailing).offset(12)
                            $0.size.equalTo(22)
                        }
                        
                        owner.repostButton.snp.remakeConstraints {
                            $0.top.equalTo(owner.heartButton)
                            $0.leading.equalTo(owner.commentButton.snp.trailing).offset(12)
                            $0.size.equalTo(22)
                        }
                        
                        owner.dmButton.snp.remakeConstraints {
                            $0.top.equalTo(owner.heartButton)
                            $0.leading.equalTo(owner.repostButton.snp.trailing).offset(12)
                            $0.size.equalTo(22)
                        }
                        
                        owner.statusLabel.snp.remakeConstraints {
                            $0.top.equalTo(owner.heartButton.snp.bottom).offset(12)
                            $0.leading.equalTo(owner.heartButton)
                            $0.bottom.equalToSuperview().offset(-12)
                        }
                        completion()
                    }
                } else {
                    if let image = item.image.first {
                        self.loadImage(path: image) { [weak self] data in
                            guard let self else { return }
                            
                            DispatchQueue.main.async {
                                self.setImage(data: data.value) { data in
                                    
                                    self.mainText.snp.removeConstraints()
                                    
                                    self.mainImage.snp.remakeConstraints {
                                        $0.top.equalTo(self.profileImage.snp.bottom).offset(12)
                                        $0.horizontalEdges.equalToSuperview().inset(12)
                                        $0.height.equalTo(data).priority(999)
                                    }
                                    
                                    self.heartButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.mainImage.snp.bottom).offset(12)
                                        $0.leading.equalTo(self.mainImage)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.commentButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton)
                                        $0.leading.equalTo(self.heartButton.snp.trailing).offset(12)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.repostButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton)
                                        $0.leading.equalTo(self.commentButton.snp.trailing).offset(12)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.dmButton.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton)
                                        $0.leading.equalTo(self.repostButton.snp.trailing).offset(12)
                                        $0.size.equalTo(22)
                                    }
                                    
                                    self.statusLabel.snp.remakeConstraints {
                                        $0.top.equalTo(self.heartButton.snp.bottom).offset(12)
                                        $0.leading.equalTo(self.heartButton)
                                        $0.bottom.equalToSuperview().offset(-12)
                                    }
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    func loadImage(path: String, completion: @escaping (BehaviorRelay<Data>) -> Void) {
        let result = BehaviorRelay(value: Data())
        
        Observable.of(())
            .observe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { self.repository.requestImage(path: path) }
            .subscribe(onNext: { value in
                switch value {
                case .success(let data):
                    result.accept(data)
                    completion(result)
                case .failure(let error):
                    print(error.message)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setImage(data: Data?, completion: @escaping (CGFloat) -> ()) {
        
        mainImage.image = nil
        
        if let data = data {
            // Set image using Data
            mainImage.image = UIImage(data: data)
            mainImage.contentMode = .scaleAspectFit
            
            if let image = mainImage.image {
                let expectedHeight = mainImage.bounds.width * (image.size.height / image.size.width)
                
                mainImage.layer.borderColor = UIColor.lightGray.cgColor
                mainImage.layer.borderWidth = 0.5
                
                completion(expectedHeight)
                
            }
        }
    }
    
    override func configureView() {
        super.configureView()
        
        [profileImage, userNickname, uploadTime, moreButton, mainText, mainImage, heartButton, commentButton, repostButton, dmButton, statusLabel].forEach {
            contentView.addSubview($0)
        }
        
        heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
        commentButton.setSymbolImage(image: "message", size: 22, color: .black)
        repostButton.setSymbolImage(image: "repeat", size: 22, color: .black)
        dmButton.setSymbolImage(image: "paperplane", size: 22, color: .black)
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(38)
        }
        
        userNickname.snp.makeConstraints {
            $0.centerY.equalTo(profileImage.snp.centerY)
            $0.leading.equalTo(profileImage.snp.trailing).offset(12)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(userNickname.snp.centerY)
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(15)
        }
        
        uploadTime.snp.makeConstraints {
            $0.centerY.equalTo(userNickname.snp.centerY)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-12)
        }
        
        mainText.snp.makeConstraints {
//            $0.top.equalTo(profileImage.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
        
        mainImage.snp.makeConstraints {
//            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
//            $0.height.equalTo(500)
        }
        
        heartButton.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(12)
            $0.leading.equalTo(profileImage)
            $0.size.equalTo(22)
        }
        
        commentButton.snp.makeConstraints {
            $0.top.equalTo(heartButton)
            $0.leading.equalTo(heartButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        repostButton.snp.makeConstraints {
            $0.top.equalTo(heartButton)
            $0.leading.equalTo(commentButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        dmButton.snp.makeConstraints {
            $0.top.equalTo(heartButton)
            $0.leading.equalTo(repostButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(heartButton.snp.bottom).offset(12)
            $0.leading.equalTo(heartButton)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
    }
    
}
