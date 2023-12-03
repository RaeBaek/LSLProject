//
//  BackView.swift
//  LSLProject
//
//  Created by 백래훈 on 12/3/23.
//

import UIKit

final class BackView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.layer.frame.height / 2
        clipsToBounds = true
        
    }
    
}
