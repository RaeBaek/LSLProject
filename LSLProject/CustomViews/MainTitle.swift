//
//  MainTitle.swift
//  LSLProject
//
//  Created by 백래훈 on 12/7/23.
//

import UIKit

final class MainTitle: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.textColor = .black
        self.font = .systemFont(ofSize: 14, weight: .regular)
        self.textAlignment = .left
        self.numberOfLines = 0
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
