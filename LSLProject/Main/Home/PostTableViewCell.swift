//
//  HomeTableViewCell.swift
//  LSLProject
//
//  Created by 백래훈 on 11/25/23.
//

import UIKit
import SnapKit
import Kingfisher

import RxSwift
import RxCocoa
import Moya

class PostTableViewCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: PostTableViewCell.identifier)
        
        heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
        commentButton.setSymbolImage(image: "message", size: 22, color: .black)
        repostButton.setSymbolImage(image: "repeat", size: 22, color: .black)
        dmButton.setSymbolImage(image: "paperplane", size: 22, color: .black)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let profileImageButton = DeleteButton(frame: .zero)
    var profileImage = ProfileImageView(frame: .zero)
    var userNickname = NicknameLabel(frame: .zero)
    var uploadTime = UploadTimeLabel(frame: .zero)
    
    lazy var moreButton = MoreButton(frame: .zero)
    
    var mainText =  MainTitle(frame: .zero)
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
    
    private let bottomLine = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let repository = NetworkRepository()
    
    var disposeBag = DisposeBag()
    
    var element: PostResponse?
    
    lazy var status = Observable.of(element)
    
    var likes: Int = 0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 재사용될 때의 상황을 고려해야함!
        mainText.text = nil
        mainImage.image = nil
        mainImage.layer.borderWidth = 0
        mainImage.layer.borderColor = nil
        profileImage.image = UIImage(named: "basicUser")
        heartButton.setSymbolImage(image: "heart", size: 22, color: .black)
        
        disposeBag = DisposeBag()

        mainText.snp.remakeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        mainImage.snp.remakeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        heartButton.snp.remakeConstraints {
            $0.top.equalTo(userNickname.snp.bottom).offset(12)
            $0.leading.equalTo(userNickname)
            $0.size.equalTo(22)
        }
        
        commentButton.snp.remakeConstraints {
            $0.top.equalTo(heartButton)
            $0.leading.equalTo(heartButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        repostButton.snp.remakeConstraints {
            $0.top.equalTo(heartButton)
            $0.leading.equalTo(commentButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        dmButton.snp.remakeConstraints {
            $0.top.equalTo(heartButton)
            $0.leading.equalTo(repostButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        statusLabel.snp.remakeConstraints {
            $0.top.equalTo(heartButton.snp.bottom).offset(16)
            $0.leading.equalTo(heartButton)
            
        }
        
        bottomLine.snp.remakeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(16)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
    }
    
    func setCell(element: PostResponse, completion: @escaping () -> ()) {
        
        if let profileURL = element.creator.profile {
            let url = URL(string: APIKey.sesacURL + profileURL)
            profileImage.kf.setImage(with: url, options: [.requestModifier(imageDownloadRequest)])
        }
        
        if element.likes.contains(UserDefaultsManager.id) {
            heartButton.setSymbolImage(image: "heart.fill", size: 22, color: .systemRed)
        }
        
        self.likes = element.likes.count
        userNickname.text = element.creator.nick
        
        selectionStyle = .none
        
        if element.title != "" {
            mainText.text = element.title
            
            if let image = element.image.first {
                loadImage(path: image) { [weak self] data in
                    guard let self else { return }
                    
                    DispatchQueue.main.async {
                        
                        self.mainImage.layer.borderWidth = 0.5
                        self.mainImage.layer.borderColor = UIColor.lightGray.cgColor
                        
                        self.setImage(data: data.value) { data in
                            
                            self.mainText.snp.remakeConstraints {
                                $0.top.equalTo(self.userNickname.snp.bottom).offset(6)
                                $0.leading.equalTo(self.userNickname)
                                $0.trailing.equalToSuperview().offset(-12)
                            }
                            
                            self.mainImage.snp.remakeConstraints {
                                $0.top.equalTo(self.mainText.snp.bottom).offset(8)
                                $0.leading.equalTo(self.userNickname)
                                $0.trailing.equalToSuperview().offset(-12)
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
                                $0.top.equalTo(self.heartButton.snp.bottom).offset(16)
                                $0.leading.equalTo(self.heartButton)
                                
                            }
                            
                            self.bottomLine.snp.remakeConstraints {
                                $0.top.equalTo(self.statusLabel.snp.bottom).offset(16)
                                $0.horizontalEdges.bottom.equalToSuperview()
                                $0.height.equalTo(0.5)
                            }
                            completion()
                        }
                    }
                }
            } else {
                mainText.snp.remakeConstraints {
                    $0.top.equalTo(userNickname.snp.bottom).offset(6)
                    $0.leading.equalTo(userNickname)
                    $0.trailing.equalToSuperview().offset(-12)
                }
                
                mainImage.snp.removeConstraints()
                
                heartButton.snp.remakeConstraints {
                    $0.top.equalTo(mainText.snp.bottom).offset(12)
                    $0.leading.equalTo(mainText)
                    $0.size.equalTo(22)
                }
                
                commentButton.snp.remakeConstraints {
                    $0.top.equalTo(heartButton)
                    $0.leading.equalTo(heartButton.snp.trailing).offset(12)
                    $0.size.equalTo(22)
                }
                
                repostButton.snp.remakeConstraints {
                    $0.top.equalTo(heartButton)
                    $0.leading.equalTo(commentButton.snp.trailing).offset(12)
                    $0.size.equalTo(22)
                }
                
                dmButton.snp.remakeConstraints {
                    $0.top.equalTo(heartButton)
                    $0.leading.equalTo(repostButton.snp.trailing).offset(12)
                    $0.size.equalTo(22)
                }
                
                statusLabel.snp.remakeConstraints {
                    $0.top.equalTo(heartButton.snp.bottom).offset(16)
                    $0.leading.equalTo(heartButton)
                    
                }
                
                bottomLine.snp.remakeConstraints {
                    $0.top.equalTo(statusLabel.snp.bottom).offset(16)
                    $0.horizontalEdges.bottom.equalToSuperview()
                    $0.height.equalTo(0.5)
                }
                completion()
            }
        } else {
            if let image = element.image.first {
                loadImage(path: image) { [weak self] data in
                    guard let self else { return }
                    
                    DispatchQueue.main.async {
                        
                        self.mainImage.layer.borderWidth = 0.5
                        self.mainImage.layer.borderColor = UIColor.lightGray.cgColor
                        
                        self.setImage(data: data.value) { data in
                            
                            self.mainText.snp.removeConstraints()
                            
                            self.mainImage.snp.remakeConstraints {
                                $0.top.equalTo(self.userNickname.snp.bottom).offset(8)
                                $0.leading.equalTo(self.userNickname)
                                $0.trailing.equalToSuperview().offset(-12)
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
                                $0.top.equalTo(self.heartButton.snp.bottom).offset(16)
                                $0.leading.equalTo(self.heartButton)
                                
                            }
                            
                            self.bottomLine.snp.remakeConstraints {
                                $0.top.equalTo(self.statusLabel.snp.bottom).offset(16)
                                $0.horizontalEdges.bottom.equalToSuperview()
                                $0.height.equalTo(0.5)
                            }
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    private func loadImage(path: String, completion: @escaping (BehaviorRelay<Data>) -> Void) {
        
        let result = BehaviorRelay(value: Data())
        
        Observable.of(())
            .observe(on: SerialDispatchQueueScheduler(qos: .userInteractive))
            .flatMap { self.repository.requestImage(path: path) }
            .subscribe(onNext: { value in
                print("================================= \(value)")
                switch value {
                case .success(let data):
                    result.accept(data)
                    completion(result)
                    print("================data============= \(data)")
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
    
    override func configureCell() {
        super.configureCell()
        
        [profileImageButton, profileImage, userNickname, lineBar, uploadTime, moreButton, mainText, mainImage, heartButton, commentButton, repostButton, dmButton, statusLabel, bottomLine].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImageButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(38)
        }
        
        profileImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(38)
        }
        
        userNickname.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(profileImage.snp.trailing).offset(12)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(userNickname.snp.centerY)
            $0.trailing.equalToSuperview().inset(12)
            $0.size.equalTo(15)
        }
        
        uploadTime.snp.makeConstraints {
            $0.centerY.equalTo(userNickname.snp.centerY)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-12)
        }
        
        lineBar.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(8)
            $0.centerX.equalTo(profileImage)
            $0.bottom.equalTo(heartButton.snp.bottom).offset(6)
            $0.width.equalTo(2)
        }
        
        mainText.snp.makeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        mainImage.snp.makeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        heartButton.snp.makeConstraints {
            $0.top.equalTo(userNickname.snp.bottom).offset(12)
            $0.leading.equalTo(userNickname)
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
            $0.top.equalTo(heartButton.snp.bottom).offset(16)
            $0.leading.equalTo(heartButton)
        }
        
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(16)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
    }
    
}
