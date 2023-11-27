//
//  HomeTableViewCell.swift
//  LSLProject
//
//  Created by 백래훈 on 11/25/23.
//

import UIKit
import SnapKit

class HomeTableViewCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: HomeTableViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var profileImage = {
        let view = ProfileImageView(frame: .zero)
        view.contentMode = .scaleToFill
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
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
        return view
    }()
    
    var mainImage = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .systemGreen
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
    
    private let bottomLine = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
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
            $0.top.equalTo(profileImage.snp.top)
            $0.leading.equalTo(profileImage.snp.trailing).offset(12)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(userNickname.snp.centerY)
            $0.trailing.equalToSuperview().inset(12)
            $0.size.equalTo(22)
        }
        
        uploadTime.snp.makeConstraints {
            $0.centerY.equalTo(userNickname.snp.centerY)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-12)
        }
        
        mainText.snp.makeConstraints {
            $0.bottom.equalTo(profileImage.snp.bottom)
            $0.leading.equalTo(profileImage.snp.trailing).offset(12)
        }
        
        mainImage.snp.makeConstraints {
            $0.top.equalTo(mainText.snp.bottom).offset(12)
            $0.leading.equalTo(lineBar.snp.trailing).offset(30)
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(500)
        }
        
        lineBar.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(2)
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