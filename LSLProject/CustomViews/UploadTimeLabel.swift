//
//  UploadTimeLabel.swift
//  LSLProject
//
//  Created by 백래훈 on 12/7/23.
//

import UIKit

final class UploadTimeLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textColor = .lightGray
        self.font = .systemFont(ofSize: 12, weight: .regular)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
