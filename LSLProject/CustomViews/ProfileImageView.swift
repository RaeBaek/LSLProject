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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.layer.frame.width / 2
        clipsToBounds = true
        
    }
    
}
