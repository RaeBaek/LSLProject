//
//  CommentEditViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 12/26/23.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

final class CommentEditViewController: BaseViewController {
    
    lazy var dismissBarbutton = {
        let view = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    lazy var moreBarbutton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: nil)
        view.tintColor = .black
        return view
    }()
    
    private let scrollView = {
        let view = UIScrollView()
        view.backgroundColor = .systemBackground
        view.isScrollEnabled = true
        return view
    }()
    
    private let contentView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    let userProfileImage = ProfileImageView(frame: .zero)
    var userNickname = NicknameLabel(frame: .zero)
    private let userLineBar = CustomLineBar(frame: .zero)
    let userTextLabel = MainTitle(frame: .zero)
    let userImageView = MainImageView(frame: .zero)
    let myProfileImage = ProfileImageView(frame: .zero)
    var myNickname = NicknameLabel(frame: .zero)
    lazy var myTextView = CustomTextView(frame: .zero, textContainer: .none)
    private let myLineBar = CustomLineBar(frame: .zero)
    
    var scrollDelegate: ScrollToBottom?
    var commentRow: Int?
    var row: Int?
    var postID: String?
    var commentID: String?
    
    let toolView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    let replyAllowButton = {
        let view = UIButton()
        let attributedTitle = NSAttributedString(string: "내 팔로워에게 답글 허용",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular),
                                                              NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.setAttributedTitle(attributedTitle, for: .normal)
        return view
    }()
    
    let postButton = {
        let view = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .black
        config.cornerStyle = .capsule
        
        var titleAttr = AttributedString.init("완료")
        titleAttr.font = .systemFont(ofSize: 13, weight: .regular)
        config.attributedTitle = titleAttr
        
        view.configuration = config
        return view
    }()
    
    var post: PostResponse?
    
    var sendDelegate: SendData?
    
    private let repository = NetworkRepository()
    
    private lazy var viewModel = CommentEditViewModel(commentID: commentID!, repository: repository)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
    }
    
    private func bind() {
        let input = CommentEditViewModel.Input(postID: BehaviorRelay(value: postID!),
                                               textViewText: myTextView.rx.text.orEmpty,
                                               textViewBeginEditing: myTextView.rx.didBeginEditing,
                                               textViewEndEditing: myTextView.rx.didEndEditing,
                                               postEditButtonTap: postButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        myTextView.rx.didChange
            .withUnretained(self)
            .bind { owner, _ in
                owner.myTextView.sizeToFit()
                // UIScrollView의 contentSize 업데이트
                owner.scrollView.contentSize = owner.contentView.frame.size
            }
            .disposed(by: disposeBag)
        
        myTextView.rx.didBeginEditing
            .withUnretained(self)
            .bind { owner, _ in
                owner.myTextView.sizeToFit()
                // UIScrollView의 contentSize 업데이트
                owner.scrollView.contentSize = owner.contentView.frame.size
            }
            .disposed(by: disposeBag)
        
        output.textViewBeginEditing
            .withUnretained(self)
            .bind { owner, _ in
                if owner.myTextView.textColor == UIColor.lightGray {
                    owner.myTextView.text = nil
                    owner.myTextView.textColor = .black
                }
            }
            .disposed(by: disposeBag)
        
        output.textViewEndEditing
            .withUnretained(self)
            .bind { owner, bool in
                if bool {
                    owner.myTextView.text = StartMessage.comment.placeholder
                    owner.myTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        output.postButtonStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.postButton.isEnabled = value
            }
            .disposed(by: disposeBag)
        
        output.postEditStatus
            .withUnretained(self)
            .bind { owner, bool in
                guard let row = owner.row, let postID = owner.postID else { return }
                
                if bool {
                    // 댓글을 수정했을 때!
//                    owner.scrollDelegate?.reloadAddComment(row: row, id: postID)
                    
                    NotificationCenter.default.post(name: Notification.Name("recallCommentAPI"), object: nil, userInfo: ["recallCommentAPI": ()])
                    
//                    owner.sendDelegate?.sendData(data: ())
                    owner.dismissViewController()
                }
            }
            .disposed(by: disposeBag)
        
        output.currentData
            .withUnretained(self)
            .bind { owner, value in
                
                if let userProfile = value.creator.profile {
                    let userProfileURL = URL(string: APIKey.sesacURL + userProfile)
                    owner.userProfileImage.kf.setImage(with: userProfileURL, options: [.requestModifier(owner.imageDownloadRequest)])
                } else {
                    owner.userProfileImage.image = UIImage(named: "basicUser")
                }
                
                let myProfile = UserDefaultsManager.profile
                
                if myProfile != "basicUser" {
                    let myProfileImageUrl = URL(string: APIKey.sesacURL + myProfile)
                    owner.myProfileImage.kf.setImage(with: myProfileImageUrl, options: [.requestModifier(owner.imageDownloadRequest)])
                } else {
                    owner.myProfileImage.image = UIImage(named: myProfile)
                }
                
                owner.userNickname.text = value.creator.nick
                owner.myNickname.text = UserDefaultsManager.nickname
                owner.myTextView.text = value.comments[owner.commentRow!].content
                owner.myTextView.textColor = .black
                
                if value.title != "" {
                    owner.userTextLabel.text = value.title
                    
                    if let image = value.image.first {
                        owner.loadImage(path: image) { [weak self] data in
                            guard let self else { return }
                            
                            DispatchQueue.main.async {
                                self.setImage(data: data.value) { data in
                                    
                                    self.userTextLabel.snp.remakeConstraints {
                                        $0.top.equalTo(self.userNickname.snp.bottom).offset(6)
                                        $0.leading.equalTo(self.userNickname)
                                        $0.trailing.equalToSuperview().offset(-12)
                                    }
                                    
                                    self.userImageView.snp.makeConstraints {
                                        $0.top.equalTo(self.userTextLabel.snp.bottom).offset(8)
                                        $0.leading.equalTo(self.userTextLabel)
                                        $0.trailing.equalToSuperview().offset(-12)
                                        $0.height.equalTo(data).priority(999)
                                    }
                                    
                                    self.myNickname.snp.makeConstraints {
                                        $0.top.equalTo(self.userImageView.snp.bottom).offset(16)
                                        $0.leading.equalTo(self.userImageView)
                                    }
                                    
                                    self.myProfileImage.snp.makeConstraints {
                                        $0.top.equalTo(self.myNickname)
                                        $0.centerX.equalTo(self.userProfileImage)
                                        $0.size.equalTo(self.userProfileImage)
                                    }
                                    
                                    self.userLineBar.snp.makeConstraints {
                                        $0.centerX.equalTo(self.userProfileImage)
                                        $0.top.equalTo(self.userProfileImage.snp.bottom).offset(8)
                                        $0.bottom.equalTo(self.myProfileImage.snp.top).offset(-8)
                                        $0.width.equalTo(2)
                                    }
                                    
                                    self.myTextView.snp.makeConstraints {
                                        $0.top.equalTo(self.myNickname.snp.bottom).offset(6)
                                        $0.leading.equalTo(self.myNickname)
                                        $0.trailing.equalToSuperview().offset(-12)
                                        $0.bottom.equalToSuperview().offset(-25)
                                    }
                                    
                                    self.myLineBar.snp.makeConstraints {
                                        $0.top.equalTo(self.myProfileImage.snp.bottom).offset(8)
                                        $0.centerX.equalTo(self.myProfileImage)
                                        $0.bottom.equalToSuperview().offset(-6)
                                        $0.width.equalTo(2)
                                    }
                                }
                            }
                        }
                    } else {
                        owner.userTextLabel.snp.remakeConstraints {
                            $0.top.equalTo(owner.userNickname.snp.bottom).offset(6)
                            $0.leading.equalTo(owner.userNickname)
                            $0.trailing.equalToSuperview().offset(-12)
                        }
                        
                        owner.userImageView.snp.removeConstraints()
                        
                        owner.myNickname.snp.makeConstraints {
                            $0.top.equalTo(owner.userTextLabel.snp.bottom).offset(20)
                            $0.leading.equalTo(owner.userTextLabel)
                        }
                        
                        owner.myProfileImage.snp.makeConstraints {
                            $0.top.equalTo(owner.myNickname)
                            $0.centerX.equalTo(owner.userProfileImage)
                            $0.size.equalTo(owner.userProfileImage)
                        }
                        
                        owner.userLineBar.snp.makeConstraints {
                            $0.centerX.equalTo(owner.userProfileImage)
                            $0.top.equalTo(owner.userProfileImage.snp.bottom).offset(8)
                            $0.bottom.equalTo(owner.myProfileImage.snp.top).offset(-8)
                            $0.width.equalTo(2)
                        }
                        
                        owner.myTextView.snp.makeConstraints {
                            $0.top.equalTo(owner.myNickname.snp.bottom).offset(6)
                            $0.leading.equalTo(owner.myNickname)
                            $0.trailing.equalToSuperview().offset(-12)
                            $0.bottom.equalToSuperview().offset(-25)
                        }
                        
                        owner.myLineBar.snp.makeConstraints {
                            $0.top.equalTo(owner.myProfileImage.snp.bottom).offset(8)
                            $0.centerX.equalTo(owner.myProfileImage)
                            $0.bottom.equalToSuperview().offset(-6)
                            $0.width.equalTo(2)
                        }
                    }
                } else {
                    if let image = value.image.first {
                        
                        owner.loadImage(path: image) { [weak self] data in
                            guard let self else { return }
                            
                            DispatchQueue.main.async {
                                self.setImage(data: data.value) { data in
                                    
                                    self.userTextLabel.snp.removeConstraints()
                                    
                                    self.userImageView.snp.makeConstraints {
                                        $0.top.equalTo(self.userNickname.snp.bottom).offset(8)
                                        $0.leading.equalTo(self.userNickname)
                                        $0.trailing.equalToSuperview().offset(-12)
                                        $0.height.equalTo(data).priority(999)
                                    }
                                    
                                    self.myNickname.snp.makeConstraints {
                                        $0.top.equalTo(self.userImageView.snp.bottom).offset(16)
                                        $0.leading.equalTo(self.userImageView)
                                    }
                                    
                                    self.myProfileImage.snp.makeConstraints {
                                        $0.top.equalTo(self.myNickname)
                                        $0.centerX.equalTo(self.userProfileImage)
                                        $0.size.equalTo(self.userProfileImage)
                                    }
                                    
                                    self.userLineBar.snp.makeConstraints {
                                        $0.centerX.equalTo(self.userProfileImage)
                                        $0.top.equalTo(self.userProfileImage.snp.bottom).offset(8)
                                        $0.bottom.equalTo(self.myProfileImage.snp.top).offset(-8)
                                        $0.width.equalTo(2)
                                    }
                                    
                                    self.myTextView.snp.makeConstraints {
                                        $0.top.equalTo(self.myNickname.snp.bottom).offset(6)
                                        $0.leading.equalTo(self.myNickname)
                                        $0.trailing.equalToSuperview().offset(-12)
                                        $0.bottom.equalToSuperview().offset(-25)
                                    }
                                    
                                    self.myLineBar.snp.makeConstraints {
                                        $0.top.equalTo(self.myProfileImage.snp.bottom).offset(8)
                                        $0.centerX.equalTo(self.myProfileImage)
                                        $0.bottom.equalToSuperview().offset(-6)
                                        $0.width.equalTo(2)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
        
    }
    
    private func setNavigationBar() {
        title = "게시물 수정"
        
        self.navigationItem.leftBarButtonItem = dismissBarbutton
        self.navigationItem.rightBarButtonItem = moreBarbutton
    }
    
    private func setImage(data: Data?, completion: @escaping (CGFloat) -> ()) {
        
        userImageView.image = nil
        
        if let data = data {
            // Set image using Data
            userImageView.image = UIImage(data: data)
            
            if let image = userImageView.image {
                let expectedHeight = userImageView.bounds.width * (image.size.height / image.size.width)
                
                userImageView.layer.borderColor = UIColor.lightGray.cgColor
                userImageView.layer.borderWidth = 0.5
                
                completion(expectedHeight)
            }
        }
    }
    
    func loadImage(path: String, completion: @escaping (BehaviorRelay<Data>) -> Void) {
        
        let result = BehaviorRelay(value: Data())
        
        Observable.of(())
            .observe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
            .withUnretained(self)
            .flatMap { owner, value in
                owner.repository.requestImage(path: path)
            }
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
    
    override func configureView() {
        super.configureView()
        
        view.addSubview(scrollView)
        view.addSubview(toolView)
        
        [replyAllowButton, postButton].forEach {
            toolView.addSubview($0)
        }
        
        scrollView.addSubview(contentView)
        
        [userNickname, userProfileImage, userTextLabel, userImageView, userLineBar,
         myNickname, myProfileImage, myTextView, myLineBar].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        scrollView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        toolView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            $0.height.equalTo(48)
        }
        
        replyAllowButton.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-6)
            $0.leading.equalToSuperview().offset(12)
        }
        
        postButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.bottom.equalToSuperview().offset(-12)
            $0.width.equalTo(50)
        }
        
        contentView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        userProfileImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(38)
        }
        
        userNickname.snp.makeConstraints {
            $0.top.equalTo(userProfileImage)
            $0.leading.equalTo(userProfileImage.snp.trailing).offset(12)
        }
        
        userTextLabel.snp.makeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        userImageView.snp.makeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
    }
    
}
