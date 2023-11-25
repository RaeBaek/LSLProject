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
    
    let profileImage = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .systemRed
        return view
    }()
    
    let userNickname = {
        let view = UILabel()
        view.text = "100_r_h"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()
    
    let uploadTime = {
        let view = UILabel()
        view.text = "3시간"
        view.textColor = .systemGray4
        view.font = .systemFont(ofSize: 13, weight: .regular)
        return view
    }()
    
    let moreButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let mainTitle = {
        let view = UILabel()
        view.text = "업로드 완료!"
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()
    
    let mainImage = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .systemGreen
        return view
    }()
    
    let lineBar = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    let heartButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "heart", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let commentButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "message", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let repostButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "repeat", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let dmButton = {
        let view = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25)
        let image = UIImage(systemName: "paperplane", withConfiguration: imageConfig)
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    let statusLabel = {
        let view = UILabel()
        view.text = "35 답글 250 좋아요"
        view.textColor = .systemGray4
        view.font = .systemFont(ofSize: 13, weight: .regular)
        return view
    }()
    
    override func configureCell() {
        super.configureCell()
        
        [profileImage, userNickname, lineBar, uploadTime, moreButton, mainTitle, mainImage, heartButton, commentButton, repostButton, dmButton, statusLabel].forEach {
            contentView.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImage.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(34)
        }
        
        userNickname.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(profileImage.snp.trailing).offset(16)
        }
        
        moreButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(25)
        }
        
        uploadTime.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-16)
        }
        
        mainTitle.snp.makeConstraints {
            $0.bottom.equalTo(profileImage.snp.bottom)
            $0.leading.equalTo(profileImage.snp.trailing).offset(16)
        }
//        
        mainImage.snp.makeConstraints {
            $0.top.equalTo(mainTitle.snp.bottom).offset(16)
            $0.leading.equalTo(lineBar.snp.trailing).offset(32)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(500)
        }
        
        lineBar.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(32)
            $0.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(2)
        }
//        
        heartButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(16)
            $0.leading.equalTo(mainImage.snp.leading)
            $0.size.equalTo(25)
        }
        
        commentButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(16)
            $0.leading.equalTo(heartButton.snp.trailing).offset(16)
            $0.size.equalTo(25)
        }
        
        repostButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(16)
            $0.leading.equalTo(commentButton.snp.trailing).offset(16)
            $0.size.equalTo(25)
        }
        
        dmButton.snp.makeConstraints {
            $0.top.equalTo(mainImage.snp.bottom).offset(16)
            $0.leading.equalTo(repostButton.snp.trailing).offset(16)
            $0.size.equalTo(25)
        }
//        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(heartButton.snp.bottom).offset(25)
            $0.leading.equalTo(heartButton.snp.leading)
            $0.bottom.equalToSuperview().inset(25)
        }
        
        
    }
    
}
