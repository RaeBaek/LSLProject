//
//  HomeDetailPostCell.swift
//  LSLProject
//
//  Created by 백래훈 on 12/1/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class HomeDetailPostHeaderView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var profileImage = {
        let view = ProfileImageView(frame: .zero)
        view.contentMode = .scaleToFill
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
        view.contentMode = .scaleToFill
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
        view.backgroundColor = .systemGray4
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
    
    private let disposeBag = DisposeBag()
    
    private let repository = NetworkRepository()
    
    func loadImage(path: String, completion: @escaping (BehaviorRelay<Data>) -> Void) {
        
        let result = BehaviorRelay(value: Data())
        
        Observable.of(())
            .observe(on: SerialDispatchQueueScheduler(qos: .background))
            .flatMap { self.repository.reqeustImage(path: path) }
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
    
    private func configureView() {
        
        [profileImage, userNickname, uploadTime, moreButton, mainText, mainImage, heartButton, commentButton, repostButton, dmButton, statusLabel].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    private func setConstraints() {
        
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
            $0.top.equalTo(profileImage.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
        }
        
        mainImage.snp.makeConstraints {
            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.height.equalTo(500)
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
            $0.top.equalTo(heartButton.snp.bottom).offset(12)
            $0.leading.equalTo(heartButton.snp.leading)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
    }
    
}
