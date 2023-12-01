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

class HomeDetailCommentCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: HomeDetailCommentCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        profileImage.image = nil
    }
    
    var profileImage = {
        let view = ProfileImageView(frame: .zero)
        view.contentMode = .scaleToFill
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        view.image = UIImage(systemName: "star")
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
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 22)
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
    
    private let repository = NetworkRepository()
    
    private let disposeBag = DisposeBag()
    
    func loadImage(path: String, completion: @escaping (Data) -> Void) {
        
        let result = BehaviorRelay(value: Data())
        
        Observable.of(())
            .observe(on: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { self.repository.reqeustImage(path: path) }
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
        
        [profileImage, userNickname, mainText, uploadTime, moreButton, heartButton, commentButton, repostButton, dmButton, statusLabel].forEach {
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
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(22)
        }
        
        uploadTime.snp.makeConstraints {
            $0.centerY.equalTo(moreButton.snp.centerY)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-12)
        }
        
        mainText.snp.makeConstraints {
            $0.top.equalTo(userNickname.snp.bottom).offset(12)
            $0.leading.equalTo(userNickname.snp.leading)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        heartButton.snp.makeConstraints {
            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.leading.equalTo(mainText.snp.leading)
            $0.size.equalTo(22)
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
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(heartButton.snp.bottom).offset(12)
            $0.leading.equalTo(heartButton.snp.leading)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
    }
    
}
