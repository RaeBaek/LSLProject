//
//  PostViewController.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
import PhotosUI

final class PostViewController: BaseViewController {

    lazy var dismissBarbutton = {
        let view = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(dismissViewController))
        view.tintColor = .black
        return view
    }()
    
    lazy var moreBarbutton = {
        let view = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(dismissViewController))
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
    
    let profileImage = {
        let view = ProfileImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    var userNickname = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        view.textColor = .black
        view.text = "100_r_h"
        return view
    }()
    
    let startMessage = "스레드를 시작하세요..."
    
    lazy var mainTextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.text = startMessage
        view.textColor = .lightGray
        view.sizeToFit()
        view.isScrollEnabled = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        return view
    }()
    
    private let lineBar = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let myImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let imageDeleteButton = {
        let view = DeleteButton(frame: .zero)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        view.tintColor = .white
        view.backgroundColor = .black
        view.layer.opacity = 0.7
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let buttonStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16
        view.distribution = .fillEqually
        return view
    }()
    
    let albumButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let gifButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "book.pages", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let recordButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "mic", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let voteButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "line.3.horizontal.decrease", withConfiguration: imageConfig)
        view.tintColor = .lightGray
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
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
        
        var titleAttr = AttributedString.init("게시")
        titleAttr.font = .systemFont(ofSize: 13, weight: .regular)
        config.attributedTitle = titleAttr
        
        view.configuration = config
        return view
    }()
    
    let viewModel = PostViewModel(repository: NetworkRepository())
    
    var data: Data? {
        didSet(newValue) {
            imageData.accept(newValue)
        }
    }
    
    lazy var imageData = BehaviorRelay(value: data)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        bind()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollView.endEditing(true)
    }
    
    private func bind() {
        
        let input = PostViewModel.Input(postButtonTap: postButton.rx.tap,
                                        imageButtonTap: albumButton.rx.tap,
                                        textViewText: mainTextView.rx.text.orEmpty,
                                        textViewBeginEditing: mainTextView.rx.didBeginEditing,
                                        textViewEndEditing: mainTextView.rx.didEndEditing,
                                        imageData: imageData,
                                        userToken: BehaviorRelay(value: UserDefaultsManager.token))
        
        let output = viewModel.transform(input: input)
        
        output.profile
            .withUnretained(self)
            .bind { owner, value in
                owner.userNickname.text = value
            }
            .disposed(by: disposeBag)
        
        output.profileImageURL
            .withUnretained(self)
            .bind { owner, url in
                owner.profileImage.kf.setImage(with: url, options: [.requestModifier(self.imageDownloadRequest)])
            }
            .disposed(by: disposeBag)
        
        mainTextView.rx.didChange
            .withUnretained(self)
            .bind { owner, _ in
                owner.mainTextView.sizeToFit()
                // UIScrollView의 contentSize 업데이트
                owner.scrollView.contentSize = owner.contentView.frame.size
            }
            .disposed(by: disposeBag)
        
        output.textViewBeginEditing
            .withUnretained(self)
            .bind { owner, _ in
                if owner.mainTextView.textColor == UIColor.lightGray {
                    owner.mainTextView.text = nil
                    owner.mainTextView.textColor = .black
                }
            }
            .disposed(by: disposeBag)
        
        output.textViewEndEditing
            .withUnretained(self)
            .bind { owner, bool in
                if bool {
                    owner.mainTextView.text = owner.startMessage
                    owner.mainTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        output.postResult
            .withUnretained(self)
            .bind { owner, value in
                owner.dismissViewController()
            }
            .disposed(by: disposeBag)
        
        output.phpicker
            .withUnretained(self)
            .bind { owner, value in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)
        
        output.postButtonStatus
            .withUnretained(self)
            .bind { owner, value in
                owner.postButton.isEnabled = value
            }
            .disposed(by: disposeBag)
        
        imageDeleteButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.deleteImage()
            }
            .disposed(by: disposeBag)
    }
    
    private func setNavigationBar() {
        title = "새로운 스레드"
        
        self.navigationItem.leftBarButtonItem = dismissBarbutton
        self.navigationItem.rightBarButtonItem = moreBarbutton
        
        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
//        self.navigationController?.navigationBar.backgroundColor = .systemGray
    }
    
    private func presentPicker() {
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        // configuration.filter = .any(of: [.images, .livePhotos, .videos])
        
        let imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
        
    }
    
    @objc func deleteImage() {
        self.myImageView.image = nil
        self.data = nil
        
        myImageView.snp.remakeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        buttonStackView.snp.remakeConstraints {
            $0.top.equalTo(mainTextView.snp.bottom).offset(16)
            $0.leading.equalTo(mainTextView)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        imageDeleteButton.snp.removeConstraints() 
        imageDeleteButton.isHidden = true
        
        mainTextView.sizeToFit()
        scrollView.contentSize = self.contentView.frame.size
        
        buttonStackView.isHidden = false
        
    }
    
    override func configureView() {
        super.configureView()
        
        view.addSubview(scrollView)
        view.addSubview(toolView)
        
        [replyAllowButton, postButton].forEach {
            toolView.addSubview($0)
        }
        
        scrollView.addSubview(contentView)
        
        [profileImage, userNickname, mainTextView, myImageView, lineBar, buttonStackView, imageDeleteButton].forEach {
            contentView.addSubview($0)
        }
        
        [albumButton, gifButton, recordButton, voteButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        scrollView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(toolView.snp.top).offset(-12)
        }
        
        toolView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            $0.height.equalTo(48)
        }
        
        contentView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
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
        
        mainTextView.snp.makeConstraints {
            $0.top.equalTo(userNickname.snp.bottom).offset(6)
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        myImageView.snp.makeConstraints {
            $0.leading.equalTo(userNickname)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        lineBar.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(16)
            $0.centerX.equalTo(profileImage)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.equalTo(2)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(mainTextView.snp.bottom).offset(16)
            $0.leading.equalTo(mainTextView)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        albumButton.snp.makeConstraints {
            $0.size.equalTo(25)
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
        
    }

}

extension PostViewController: PHPickerViewControllerDelegate {
    
    func compressImage(image: UIImage, targetSize: Int) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)

        while (imageData?.count ?? 0) > targetSize && compression > 0 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }

        return imageData
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                
                DispatchQueue.main.sync { [weak self] in
                    guard let self else { return }
                    
                    let image = image as? UIImage
                    
                    let originalImage: UIImage = image!// 원본 이미지
                    
                    let targetSize: Int = 1 * 1024 * 1024 // 1MB
                    
                    if let compressedImageData = compressImage(image: originalImage, targetSize: targetSize) {
                        
                        // 압축된 이미지 데이터 사용
                        print("압축된 이미지 입니다! \(compressedImageData)")
                        self.myImageView.image = UIImage(data: compressedImageData) //image as? UIImage
                        self.imageData.accept(compressedImageData)
                    } else {
                        print("압축된 이미지가 아닙니다 \(image?.jpegData(compressionQuality: 0.3))")
                        // 압축 실패 또는 원본 이미지가 이미 충분히 작을 때
                        self.myImageView.image = UIImage(data: (image?.jpegData(compressionQuality: 0.3))!) //image as? UIImage
                        self.imageData.accept(image?.jpegData(compressionQuality: 0.3))
                        
                    }
                    
                    if self.myImageView.image != nil {
                        
                        let expectedHeight = self.myImageView.bounds.width * (originalImage.size.height / originalImage.size.width)
                        
                        myImageView.snp.remakeConstraints {
                            $0.top.equalTo(self.mainTextView.snp.bottom).offset(16)
                            $0.leading.equalTo(self.mainTextView)
                            $0.trailing.equalToSuperview().offset(-18)
                            // 이미지 높이 계산 식 추가할 것. PostTableViewCell 참고!
                            $0.height.equalTo(expectedHeight)
                        }
                        
                        imageDeleteButton.snp.remakeConstraints {
                            $0.top.equalTo(self.myImageView.snp.top).offset(20)
                            $0.trailing.equalTo(self.myImageView.snp.trailing).offset(-20)
                            $0.size.equalTo(25)
                        }
                        
                        buttonStackView.snp.remakeConstraints {
                            $0.top.equalTo(self.myImageView.snp.bottom).offset(16)
                            $0.leading.equalTo(self.myImageView)
                            $0.bottom.equalToSuperview()
                        }
                        
                        imageDeleteButton.isHidden = false
                        
                        mainTextView.sizeToFit()
                        scrollView.contentSize = self.contentView.frame.size
                        
                        buttonStackView.isHidden = true
                        
//                        [albumButton, gifButton, recordButton, voteButton].forEach {
//                            $0.isHidden = true
//                        }
                        
                    } else {
                        myImageView.snp.remakeConstraints {
                            $0.top.equalTo(self.mainTextView.snp.bottom).offset(16)
                            $0.leading.equalTo(self.mainTextView)
                            $0.trailing.equalToSuperview().offset(-18)
                        }
                        
                        imageDeleteButton.snp.removeConstraints()
                        
                        buttonStackView.isHidden = false
                        
//                        [albumButton, gifButton, recordButton, voteButton].forEach {
//                            $0.isHidden = false
//                        }
                    }
                    
                }
            }
        }
    }
}
