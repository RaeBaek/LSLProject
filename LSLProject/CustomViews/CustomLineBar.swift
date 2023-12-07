//
//  CustomLineBar.swift
//  LSLProject
//
//  Created by 백래훈 on 12/7/23.
//

import UIKit

final class CustomLineBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 1
        self.clipsToBounds = true
        self.backgroundColor = .systemGray5
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
