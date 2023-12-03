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

class HomeTableViewCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: HomeTableViewCell.identifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var profileImage = {
        let view = ProfileImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    var userNickname = {
        let view = UILabel()
        view.text = "100_r_h"
        view.textColor = .black
        view.font = .systemFont(ofSize: 14, weight: .semibold)
        return view
    }()
    
    var uploadTime = {
        let view = UILabel()
        view.text = "3시간"
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 13, weight: .regular)
        return view
    }()
    
    private let moreButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15)
        let image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    var mainText = {
        let view = UILabel()
        view.text = "업로드 완료!"
        view.textColor = .black
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textAlignment = .left
        view.numberOfLines = 0
        return view
    }()
    
    var mainImage = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        return view
    }()
    
    private let lineBar = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        return view
    }()
    
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
    
    var statusLabel = {
        let view = UILabel()
        view.text = "35 답글 250 좋아요"
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 13, weight: .regular)
        return view
    }()
    
    private let bottomLine = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private let repository = NetworkRepository()
    
    let disposeBag = DisposeBag()
    
    // 이미지 뷰의 leading 제약
    private var imageViewLeadingConstraint: Constraint?
    // 이미지 뷰의 trailing 제약
    private var imageViewTrailingConstraint: Constraint?
    
    var element: PostResponse?
    
    lazy var status = Observable.of(element)
    
    // 이미지 다운로드 작업을 관리하는 객체
    private var imageDownloadTask: Cancellable?
    
    let imageDownloadRequest = AnyModifier { request in
        var requestBody = request
        requestBody.setValue(UserDefaultsManager.token, forHTTPHeaderField: "Authorization")
        requestBody.setValue(APIKey.sesacKey, forHTTPHeaderField: "SesacKey")
        return requestBody
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mainImage.image = nil
        
        cellIndex = -1
        
        mainImage.snp.makeConstraints { make in
            make.top.equalTo(mainText.snp.bottom).offset(12)
            make.leading.equalTo(mainText)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        // 이미지 다운로드 작업을 취소
        imageDownloadTask?.cancel()
        
//        profileImage.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(16)
//            $0.leading.equalToSuperview().offset(12)
//            $0.size.equalTo(38)
//        }
//        
//        userNickname.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(16)
//            $0.leading.equalTo(profileImage.snp.trailing).offset(12)
//        }
//        
//        moreButton.snp.makeConstraints {
//            $0.centerY.equalTo(userNickname.snp.centerY)
//            $0.trailing.equalToSuperview().inset(12)
//            $0.size.equalTo(15)
//        }
//        
//        uploadTime.snp.makeConstraints {
//            $0.centerY.equalTo(userNickname.snp.centerY)
//            $0.trailing.equalTo(moreButton.snp.leading).offset(-12)
//        }
//        
//        lineBar.snp.makeConstraints {
//            $0.top.equalTo(profileImage.snp.bottom).offset(16)
//            $0.leading.equalToSuperview().offset(30)
//            $0.bottom.equalToSuperview().inset(16)
//            $0.width.equalTo(2)
//        }
//        
//        mainText.snp.makeConstraints {
//            $0.bottom.equalTo(profileImage.snp.bottom)
//            $0.leading.equalTo(userNickname.snp.leading)
//            $0.trailing.equalToSuperview().offset(-12)
//        }
//        
//        mainImage.snp.remakeConstraints { make in
//            make.top.equalTo(mainText.snp.bottom).offset(12)
//            make.leading.equalTo(mainText)
//            make.trailing.equalToSuperview().offset(-12)
//        }
//        
//        heartButton.snp.makeConstraints {
//            $0.top.equalTo(mainImage.snp.bottom).offset(12)
//            $0.leading.equalTo(mainImage.snp.leading)
//            $0.size.equalTo(22)
//        }
//        
//        commentButton.snp.makeConstraints {
//            $0.top.equalTo(mainImage.snp.bottom).offset(12)
//            $0.leading.equalTo(heartButton.snp.trailing).offset(12)
//            $0.size.equalTo(22)
//        }
//        
//        repostButton.snp.makeConstraints {
//            $0.top.equalTo(mainImage.snp.bottom).offset(12)
//            $0.leading.equalTo(commentButton.snp.trailing).offset(12)
//            $0.size.equalTo(22)
//        }
//        
//        dmButton.snp.makeConstraints {
//            $0.top.equalTo(mainImage.snp.bottom).offset(12)
//            $0.leading.equalTo(repostButton.snp.trailing).offset(12)
//            $0.size.equalTo(22)
//        }
//        
//        statusLabel.snp.makeConstraints {
//            $0.top.equalTo(heartButton.snp.bottom).offset(25)
//            $0.leading.equalTo(heartButton.snp.leading)
//        }
//        
//        bottomLine.snp.makeConstraints {
//            $0.top.equalTo(statusLabel.snp.bottom).offset(25)
//            $0.horizontalEdges.bottom.equalToSuperview()
//            $0.height.equalTo(0.5)
//        }
        
    }
    
    private var cellIndex: Int = -1
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func setCell(row: Int, element: PostResponse) {
        
//        guard let element else { return }
        
        userNickname.text = element.creator.nick
        mainText.text = element.title
        
        let path = element.image.first ?? ""
        
        print("이미지 주소: \(path)")
        
        loadImage(path: path) { [weak self] data in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.setImage(data: data.value)
                self.layoutIfNeeded()
            }
            
        }
        
        loadImage(path: element.creator.profile ?? "") { [weak self] data in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.profileImage.image = UIImage(data: data.value)
                self.layoutIfNeeded()
                
            }
        }
        
        statusLabel.text = element.productID
        
        selectionStyle = .none
        
    }
    
    private func setImage(data: Data?) {
        
        // Clear previous image
        mainImage.image = nil
        
        // Check if imageData is not nil
        if let data = data {
            // Set image using Data
            mainImage.image = UIImage(data: data)
            
            // Set initial constraints
            mainImage.snp.remakeConstraints { make in
                make.top.equalTo(mainText.snp.bottom).offset(12)
                make.leading.equalTo(mainText)
                make.trailing.equalToSuperview().offset(-12)
                
                // Calculate the expected height based on the aspect ratio
                if let image = mainImage.image {
                    let expectedHeight = mainImage.bounds.width * (image.size.height / image.size.width)
                    make.height.equalTo(expectedHeight).priority(.high)
                }
            }
        }
    }
    
    func loadImage(path: String, completion: @escaping (BehaviorRelay<Data>) -> Void) {
        
        let result = BehaviorRelay(value: Data())
        
        Observable.of(())
            .observe(on: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { self.repository.reqeustImage(path: path) }
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
    
    override func configureCell() {
        super.configureCell()
        
        [profileImage, userNickname, lineBar, uploadTime, moreButton, mainText, mainImage, heartButton, commentButton, repostButton, dmButton, statusLabel, bottomLine].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
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
        
        mainText.snp.makeConstraints {
            $0.bottom.equalTo(profileImage.snp.bottom)
            $0.leading.equalTo(userNickname.snp.leading)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        lineBar.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(16)
            $0.centerX.equalTo(profileImage)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.equalTo(2)
        }
        
        mainImage.snp.makeConstraints {

            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.leading.equalTo(mainText)
            $0.trailing.equalToSuperview().offset(-12)
//            $0.top.equalTo(mainText.snp.bottom).offset(12)
//            imageViewLeadingConstraint = $0.leading.equalTo(lineBar.snp.trailing).offset(30).constraint
//            imageViewTrailingConstraint = $0.trailing.equalToSuperview().inset(12).constraint
        }
        
        heartButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(12)
            $0.leading.equalTo(mainImage.snp.leading)
            $0.size.equalTo(22)
        }
        
        commentButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(12)
            $0.leading.equalTo(heartButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        repostButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(12)
            $0.leading.equalTo(commentButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        dmButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(12)
            $0.leading.equalTo(repostButton.snp.trailing).offset(12)
            $0.size.equalTo(22)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(heartButton.snp.bottom).offset(25)
            $0.leading.equalTo(heartButton.snp.leading)
        }
        
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(25)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        
    }
    
}
