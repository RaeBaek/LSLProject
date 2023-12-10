//
//  ProfileImage.swift
//  LSLProject
//
//  Created by 백래훈 on 11/26/23.
//

import UIKit

final class ProfileImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.image = UIImage(named: "basicUser")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.layer.frame.width / 2
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFit
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
    }
    
}
